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

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gameModeButton;

@property (weak, nonatomic) IBOutlet UISlider *historySlider;

@property (weak, nonatomic) IBOutlet UILabel *historyIndexLabel;

// note that we make this of class 'Deck' instead of a 'PlayingCardDeck', because nothing in this class is going to use anything about a PlayingCard, we're not going to call 'suit' or 'rank' or anything else -> there is no reason for that property to be any more specific about what kind of class it is than it needs to be. It makes this class more generic, which is just good OO programming. Since a PlayingCardDeck inherits from Deck, it 'IS A' deck, so it's perfectly legal to say that the 'Deck' property 'deck' equals a 'PlayingCardDeck'
// we aren't going to send any messages to self.deck that aren't understood by the base 'Deck' class. The only message we'll send is 'drawRandomCard', that's not a PlayingCardDeck method, it's a Deck method.

//@property (nonatomic, strong) Deck *deck;

// property for our game model
@property (nonatomic, strong) CardMatchingGame *game;

// keep track of all flips so we can replay everything (using a slider)
@property (strong, nonatomic) NSMutableArray* history;

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

@synthesize game = _game;

- (void)setFlipCount:(int)flipCount
{   
    // it's a setter -> don't forget to set
    _flipCount = flipCount;
    
    // using the setter to update the flipsLabel
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (void)setCardButtons:(NSArray *)cardButtons
{    
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

- (void)setGame:(CardMatchingGame *)game
{
    NSLog(@"xxx game setter called xxx");
    _game = game;
    
    [self updateUI];
}

- (NSMutableArray *)history
{
    if (!_history)
    {
        _history = [[NSMutableArray alloc] init];
    }
    return _history;
}

#pragma mark - xxx

- (void)updateUI
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
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
    
    // update the flipsLabel
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (void)addFlipEventToHistory:(NSUInteger)index
{
    [self.history addObject:[NSNumber numberWithInt:index]];
    
    NSLog(@"events in history : %d", self.history.count);
    
    // TBD : adjust slider max value
}


#pragma mark - IBAction methods

- (IBAction)flipCard:(UIButton *)sender
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // increment the count each time we flip a (playable) card up
    // we could also look at the button state here, but then we cannot use the same code for the history feature, where we 'simulate' button presses
    Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:sender]];
    if((!card.isFaceUp) & (!card.isUnplayable))
        self.flipCount++;
    
    // we won't flip cards ourselves anymore, we'll let the CardMatchingGame do it
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    
    // if flipping starts, disable the segmented control
    if (self.flipCount == 0)
        self.gameModeButton.enabled = NO;

    
    // add event to history
    [self addFlipEventToHistory:[self.cardButtons indexOfObject:sender]];
    
    // update the UI when a card gets flipped
    [self updateUI];
}

- (IBAction)startNewGame:(id)sender
{
    // because flipCount is not part of the model, it will not automatically be cleared (the score does get cleared to zero, because it's part of the model)
    self.flipCount = 0;

    // very ellegant way to start a new game is to set self.game to nil -> next time the getter of game is called (happens right after this in updateUI) -> a new pack of cards will be generated
    self.game = nil;
    
    // (re)enable the segmented control
    self.gameModeButton.enabled = YES;

    // a new game has been created -> it's convenient for the user that the game mode stays in the last selected mode
    // -> we need to set the game mode again, let's call the segmented control's action method (is there a better way/place to do this maybe???)
    [self gameModeChanged:self.gameModeButton];
    
    // clear history
    self.history = nil;
    
    // now update the UI - the call to the updateUI will create a new game the first time the getter is called!
//    [self updateUI]; -> moved to 'setGame' method
}

- (IBAction)gameModeChanged:(UISegmentedControl *)sender
{
    NSLog(@"mode changed %d", sender.selectedSegmentIndex);

    // index 0 == 2 card mode, index 1 == 3 card mode, index 2 == 4 card mode, ...
    self.game.numberOfCardsToMatch = sender.selectedSegmentIndex + 2;
}

- (IBAction)historySliderChanged:(UISlider *)sender
{
    NSLog(@"slider value : %g", sender.value);
    
    self.historyIndexLabel.text = [NSString stringWithFormat:@"%g", sender.value];
}

@end
