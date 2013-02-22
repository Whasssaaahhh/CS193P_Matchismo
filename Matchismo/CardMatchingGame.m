//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Ronny Webers on 14/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"

// "class extension"
@interface CardMatchingGame()

@property (strong, nonatomic) NSMutableArray *cards;

// let's make the score property be NOT readonly in our private implemenatation. The 'readwrite' keyword is not necessary as it is the default, but it's added here for clarity. It's perfectly fine to declare this @property twice (public & private), as long as we do so in a compatible way (for example, you could not make the public declaration nonatomic, and the prive declaration atomic).
// There will be a setter generated for this @property. But anyone using this class through it's public API will not know that (since it is readonly in it's public @interface)
@property (nonatomic, readwrite) int score;

@property (nonatomic,readwrite) NSString *status;

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
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
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
        
        // set default value for some properties
        self.numberOfCardsToMatch = 2;
    }
    
    return self;
}

- (void)resetGame
{
    // reset all cards to their beginning state
    for (Card *card in self.cards)
    {
        card.faceUp = NO;
        card.unplayable = NO;
        card.matched = NO;
    }
    
    // clear score
    self.score = 0;
    
    // clear status
    self.status = nil;
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
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // this is the guts of our class, it is where the game logic lives
    
    // grab the last card
    Card *lastCard = [self cardAtIndex:index];
    
    // make sure it's playable
    if (!lastCard.isUnplayable)
    {
        // the (last) card is playable, so we can flip it
        lastCard.faceUp = !lastCard.isFaceUp;
        
        // if the card was flipped up, we might need to play the game if enough cards are facing up
        if (lastCard.isFaceUp)
        {
            // create an array of the other cards that are faced up
            NSMutableArray *faceUpCards = [[NSMutableArray alloc] init];
            
            NSLog(@"searching for playable, faceUpCards in %d cards", self.cards.count);
            
            for (Card *aCard in self.cards)
            {
                if (aCard.isFaceUp && !aCard.isUnplayable)
                    [faceUpCards addObject:aCard];
            }
            
            NSLog(@"found %d card(s) facing up & playable", faceUpCards.count);
            
            // see if we have enough cards facing up for the current game mode
            if (faceUpCards.count == self.numberOfCardsToMatch)
            {
                // yes we have enough cards -> let's play the game
                NSLog(@"enough (%d) cards facing up - let's try to match", faceUpCards.count);
                
                // note that the Class method 'matchMultiplePlayingCards' will not only return a score, but also set the 'matched' @property of the card,
                // so we can 'disable' the card here
                // int matchScore = [card match:faceUpCards];
                int matchScore = [PlayingCard matchMultiplePlayingCards:faceUpCards];
                if (matchScore)
                {
                    NSLog(@"matches found, score = %d!", matchScore);
                    // go through ALL cards, disable the matched cards, and turn the non-matched cards
                    for (Card *aCard in self.cards)
                    {
                        if (aCard.matched)
                            aCard.unplayable = YES;
                        else
                            aCard.faceUp = NO;
                    }
                }
                else
                {
                    NSLog(@"no matches found!");
                    // go through ALL cards, turn back only playable cards
                    for (Card *aCard in self.cards)
                    {
                        if (!aCard.isUnplayable)
                            aCard.faceUp = NO;
                    }
                }
                
                // if 'lastCard' was not a matching card, we should leave it facing up, that feels more 'intuitive' to the game (personal choice)
                if (!lastCard.matched)
                    lastCard.faceUp = YES;
            }

            
            // see if flipping this card (to face up) creates a match. If we are flipping the card up, we need to 'play the game' here
//            for (Card *otherCard in self.cards)
//            {
//                if (otherCard.isFaceUp && !otherCard.isUnplayable)
//                {
//                    // if we find it, check to see if it matches using the Card's match: method
//                    // 'match:' returns how good a match was (zero if not a match)
//                    // 'match:' takes an NSArray of other cards in case a subclass can match multiple cards. Since our matching game is only a 2-card matching game, we just create a single element array using @[ ] array creation syntac (new since iOS 6)
//                    int matchScore = [card match:@[otherCard]];
//                    if (matchScore)
//                    {
//                        // if it's a match, both cards become unplayable, and we update the score
//                        NSLog(@"status : Matched %@ and %@ for %d points", card.contents, otherCard.contents, matchScore * MATCH_BONUS);
//                        otherCard.unplayable = YES;
//                        card.unplayable = YES;
//                        self.score += matchScore * MATCH_BONUS;
//                    }
//                    else
//                    {
//                        NSLog(@"status : %@ and %@ don't match! %d point penalty", card.contents, otherCard.contents, matchScore * MISMATCH_PENALTY);
//                        otherCard.faceUp = NO;
//                        self.score -= MISMATCH_PENALTY;
//                    }
//                    break;  // break out because match was found
//                }
//            }
            // let's always charge a cost to flip
            // TBD : if the player leaves one or more card(s) faced up, count extra FLIP_COST here (or even x2) !!!
            self.score -= FLIP_COST;
        }
        
        if (lastCard.isFaceUp)
            NSLog(@"status : Flipped up : %@", lastCard.contents);
        else
            NSLog(@"status : No cards flipped");
    }
}

//- (void)flipCardAtIndex:(NSUInteger)index
//{
//    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    
//    // this is the guts of our class, it is where the game logic lives
//    
//    // grab the card
//    Card *card = [self cardAtIndex:index];
//    
//    // make sure it's playable
//    if (!card.isUnplayable)
//    {
//        if (!card.isFaceUp)
//        {
//            // see if flipping this card (to face up) creates a match. If we are flipping the card up, we need to 'play the game' here
//            for (Card *otherCard in self.cards)
//            {
//                if (otherCard.isFaceUp && !otherCard.isUnplayable)
//                {
//                    // if we find it, check to see if it matches using the Card's match: method
//                    // 'match:' returns how good a match was (zero if not a match)
//                    // 'match:' takes an NSArray of other cards in case a subclass can match multiple cards. Since our matching game is only a 2-card matching game, we just create a single element array using @[ ] array creation syntac (new since iOS 6)
//                    int matchScore = [card match:@[otherCard]];
//                    if (matchScore)
//                    {
//                        // if it's a match, both cards become unplayable, and we update the score
//                        NSLog(@"status : Matched %@ and %@ for %d points", card.contents, otherCard.contents, matchScore * MATCH_BONUS);
//                        otherCard.unplayable = YES;
//                        card.unplayable = YES;
//                        self.score += matchScore * MATCH_BONUS;
//                    }
//                    else
//                    {
//                        NSLog(@"status : %@ and %@ don't match! %d point penalty", card.contents, otherCard.contents, matchScore * MISMATCH_PENALTY);
//                        otherCard.faceUp = NO;
//                        self.score -= MISMATCH_PENALTY;
//                    }
//                    break;  // break out because match was found
//                }
//            }
//            // let's always charge a cost to flip
//            self.score -= FLIP_COST;
//        }
//        
//        // the card is playable, so we can flip it
//        card.faceUp = !card.isFaceUp;
//        
//        if (card.isFaceUp)
//            NSLog(@"status : Flipped up : %@", card.contents);
//        else
//            NSLog(@"status : No cards flipped");
//    }
//}

@end
