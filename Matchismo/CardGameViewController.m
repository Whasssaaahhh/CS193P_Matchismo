//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Ronny Webers on 11/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "CardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "CardMatchingGame.h"

@interface CardGameViewController ()
// outlet collection arrays are always strong. While the view will point strongly to the UIButtons 'inside' the array, it will not point to the array itself at all, only the controller will -> the outlet needs to be strongly held in the heap by our controller
// note : remember that an NSArray points strongly to all the elements it contains, and also that each element can be of any kind
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) int flipCount;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// note that we make this of class 'Deck' instead of a 'PlayingCardDeck', because nothing in this class is going to use anything about a PlayingCard, we're not going to call 'suit' or 'rank' or anything else -> there is no reason for that property to be any more specific about what kind of class it is than it needs to be. It makes this class more generic, which is just good OO programming. Since a PlayingCardDeck inherits from Deck, it 'IS A' deck, so it's perfectly legal to say that the 'Deck' property 'deck' equals a 'PlayingCardDeck'
// we aren't going to send any messages to self.deck that aren't understood by the base 'Deck' class. The only message we'll send is 'drawRandomCard', that's not a PlayingCardDeck method, it's a Deck method.

//@property (nonatomic, strong) Deck *deck;

// property for our game model
@property (nonatomic, strong) CardMatchingGame *game;

@end

#pragma mark - Custom setters & getters

@implementation CardGameViewController

//- (Deck *)deck
//{
//    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    
//    // it's a getter -> lazy instantiation
//    if (!_deck)
//    {
//        // even though our deck @property is of class Deck, we are within our rights to set it to a PlayingCardDeck instance, since PlayingCardDeck inherits from Deck (and thus 'isa' Deck)
//        _deck = [[PlayingCardDeck alloc] init];
//    }
//    
//    return _deck;
//}

- (void)setFlipCount:(int)flipCount
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // it's a setter -> don't forget to set
    _flipCount = flipCount;
    
    // using the setter to update the flipsLabel
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (void)setCardButtons:(NSArray *)cardButtons
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // this setter get's called when iOS loads the storyboard!
    
    // it's a setter -> don't forget to set
    _cardButtons = cardButtons;

    [self updateUI];
}

- (CardMatchingGame *)game
{
    // getter -> lazy instantiation
    if (!_game)
    {
        // game adjusts automatically to the number of buttons on the screen!
        _game = [[CardMatchingGame alloc] initWithCardCount:self.cardButtons.count usingDeck:[[PlayingCardDeck alloc] init]];
    }
    
    return _game;
}

#pragma mark - xxx

- (void)updateUI
{
    // updates the user-interface by asking the CardMatchingGame what's going on
    // we just cycle through the card buttons, getting the associated Card from the CardMatchingGame
    
    for (UIButton *cardButton in self.cardButtons)
    {
        // get a Card from the model
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        
        // Set the title in the Selected state to be the Card's contents (if the contents have not changed, this will do nothing)
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        
        // we set the title when the button is both Selected & Disabled to also be the Card's contents
        // A button shows it's Normal title whenever it is in a state (or combination of states) for which you have not set a title. Our button's Normal title is the Apple logo (the back of the card)
        [cardButton setTitle:card.contents forState:UIControlStateSelected | UIControlStateDisabled];
        
        // select the card only if it isFaceUp
        cardButton.selected = card.isFaceUp;
        
        // make the card untappable if it isUnPlayable
        cardButton.enabled = !card.isUnplayable;
        
        // make disabled buttons semi-transparent
        // Any object in your view can be made transparent simply by setting this alpha @property (1.0 is fully opaque, 0.0 is fully transparant)
        cardButton.alpha = card.isUnplayable ? 0.3 : 1.0;
    }
    
    // update the score
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    
}

- (IBAction)flipCard:(UIButton *)sender
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // we won't flip cards ourselves anymore, we'll let the CardMatchingGame do it
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    
    // increment the count each time we flip
    self.flipCount++;
    
    // update the UI when a card gets flipped
    [self updateUI];
}


@end
