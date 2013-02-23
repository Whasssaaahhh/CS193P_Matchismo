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
    
    // reset tracking properties
    self.score = 0;
    self.flipCount = 0;
    self.status = nil;
}

#pragma mark - Helper methods

- (Card *)cardAtIndex:(NSUInteger)index
{
    // check to be sure the argument is not out of bounds
    return (index < self.cards.count) ? self.cards[index] : nil;
}

#define FLIP_COST 1
#define MISMATCH_PENALTY -2
#define SUIT_MATCH_BONUS 4
#define RANK_MATCH_BONUS 8

- (NSUInteger)calculateScoreFromMatchResults:(NSArray *)results
{
    NSUInteger score = 0;
    NSMutableArray *textForStatus = [[NSMutableArray alloc] init];
    
    if(results.count != 0)
    {
        self.status = @"";
        
        // there was a match -> calculate score & update status
        for (MatchDescription *description in results)
        {
            NSUInteger lastScore = 0;
            
            switch (description.matchType)
            {
                case kMATCH_TYPE_RANK:
                    lastScore = RANK_MATCH_BONUS * description.nbrOfCardsInMatch;
                    NSLog(@"rank %@ was matched %d times, you scored %d points", description.matchedItem, description.nbrOfCardsInMatch, lastScore);
                    [textForStatus addObject:[NSString stringWithFormat:@"%dx '%@' (+%d)", description.nbrOfCardsInMatch, description.matchedItem, lastScore]];
                    break;
                    
                case kMATCH_TYPE_SUIT:
                    lastScore = SUIT_MATCH_BONUS * description.nbrOfCardsInMatch;
                    NSLog(@"suit %@ was matched %d times, you scored %d points", description.matchedItem, description.nbrOfCardsInMatch, lastScore);
                    [textForStatus addObject:[NSString stringWithFormat:@"%dx '%@' (+%d)", description.nbrOfCardsInMatch, description.matchedItem, lastScore]];                 
                    break;
                    
                default:
                    NSLog(@"unsupported MATCH_TYPE?");
                    break;
            }
            
            // construct status message
            self.status = @"Match : ";
            self.status = [self.status stringByAppendingString:[textForStatus componentsJoinedByString:@", "]];
            score += lastScore;
        }
    }
    else
    {
        score += MISMATCH_PENALTY;
        self.status = [NSString stringWithFormat:@"Mismatch, score %d", MISMATCH_PENALTY];
        NSLog(@"no matches found, penalty : %d", MISMATCH_PENALTY);
    }
    
    NSLog(@"Total points gained with last flip : %d", score);
    
    return score;
}

- (void)flipCardAtIndex:(NSUInteger)index
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // this is the guts of our class, it is where the game logic lives
    
    // keep track of the score result of this flip
    NSUInteger currentFlipScore = 0;
    
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
            // keep track of the flipCount
            self.flipCount++;
            
            // create an array of the other cards that are faced up
            NSMutableArray *faceUpCards = [[NSMutableArray alloc] init];
            
            // search for playable, faceUpCards
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
                // int matchScore = [PlayingCard matchMultiplePlayingCards_v2:faceUpCards];
                MatchResults *matchResults = [[MatchResults alloc] init];
                matchResults = [PlayingCard matchMultiplePlayingCards:faceUpCards];
                
                // calculate score for this match & add it to the total score
                currentFlipScore = [self calculateScoreFromMatchResults:matchResults.results];
                self.score += currentFlipScore;
                
                if (matchResults.results.count != 0)
                {
                    NSLog(@"matches found, you gained %d points!", currentFlipScore);
                    
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

            // let's always charge a cost to flip (TBD : we could also charge extra for all cards that the user leaves facing up in a 3 or more card game, but let's KISS for now)
            self.score -= FLIP_COST;          
        }
        
        if (currentFlipScore == 0)
        {
            if (lastCard.isFaceUp)
            {
                self.status = [NSString stringWithFormat:@"flipped up : %@", lastCard.contents];
                NSLog(@"status : Flipped up : %@", lastCard.contents);
            }
            else
            {
                self.status = @"";
                NSLog(@"status : No cards flipped");
            }
        }
    }
}

@end
