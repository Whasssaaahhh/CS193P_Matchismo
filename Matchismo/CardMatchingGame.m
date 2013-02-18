//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Ronny Webers on 14/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "CardMatchingGame.h"

// "class extension"
@interface CardMatchingGame()

@property (strong, nonatomic) NSMutableArray *cards;

// let's make the score property be NOT readonly in our private implemenatation. The 'readwrite' keyword is not necessary as it is the default, but it's added here for clarity. It's perfectly fine to declare this @property twice (public & private), as long as we do so in a compatible way (for example, you could not make the public declaration nonatomic, and the prive declaration atomic).
// There will be a setter generated for this @property. But anyone using this class through it's public API will not know that (since it is readonly in it's public @interface)
@property (nonatomic, readwrite) int score;

@end

@implementation CardMatchingGame

#pragma mark - custom getters & setters

- (NSMutableArray *)cards
{
    // getter -> lazy instantiation
    if (!_cards)
        _cards = [[NSMutableArray alloc] init];
    
    return _cards;
}

#pragma mark - initializers

// This is our class's designated initializer. It means that it is not legally initialized unless this gets called at some point. We must always call our superclass's designated initializer from 'our' designated initializer. If this were just a convenience initializer, we'd have to call our 'own' designated initializer from it (which in his turn calls the designated initializer of super). NSObject's designated initializer is 'init'
//
- (id)initWithCardCount:(NSUInteger)cardCount usingDeck:(Deck *)deck
{
    // start off the initializer by letting our superclass have a chance to initialize itself (and checking for failure return of nil)
    self = [super init];
    
    if (self)
    {
        // loop through the specified 'cardCount' of cards
        for (int i = 0; i < cardCount; i++)
        {
            // draw a random card from the specified deck
            Card *card = [deck drawRandomCard];
            
            if (!card)
            {
                // protect ourselves from bad (or insufficient) decks
                NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                NSLog(@"Error - unusable deck");

                self = nil;
            }
            else
            {
                self.cards[i] = card;
            }
        }
    }
    
    return self;
}

#pragma mark - xxx

- (Card *)cardAtIndex:(NSUInteger)index
{
    // check to be sure the argument is not out of bounds
    return (index < self.cards.count) ? self.cards[index] : nil;
}

#define FLIP_COST 1
#define MISMATCH_PENALTY 2
#define MATCH_BONUS 4

- (void)flipCardAtIndex:(NSUInteger)index
{
    // this is the guts of our class, it is where the game logic lives
    
    // grab the card
    Card *card = [self cardAtIndex:index];
    
    // make sure it's playable
    if (!card.isUnplayable)
    {
        if (!card.isFaceUp)
        {
            // see if flipping this card up creates a match. If we are flipping the card up, we need to 'play the game' here
            for (Card *otherCard in self.cards)
            {
                if (otherCard.isFaceUp && !otherCard.isUnplayable)
                {
                    // if we find it, check to see if it matches using the Card's match: method
                    // 'match:' returns how good a match was (zero if not a match)
                    // 'match:' takes an NSArray of other cards in case a subclass can match multiple cards. Since our matching game is only a 2-card matching game, we just create a single element array using @[ ] array creation syntac (new since iOS 6)
                    int matchScore = [card match:@[otherCard]];
                    if (matchScore)
                    {
                        // if it's a match, both cards become unplayable, and we update the score
                        otherCard.unplayable = YES;
                        card.unplayable = YES;
                        self.score += matchScore * MATCH_BONUS;
                    }
                    else
                    {
                        otherCard.faceUp = NO;
                        self.score -= MISMATCH_PENALTY;
                    }
                    break;  // break out because match was found
                }
            }
            // let's always charge a cost to flip
            self.score -= FLIP_COST;
        }
        
        // the card is playable, so we can flip it
        card.faceUp = !card.isFaceUp;
    }
}

@end