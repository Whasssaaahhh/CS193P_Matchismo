//
//  PlayingCard.m
//  Matchismo
//
//  Created by Ronny Webers on 12/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

#pragma mark - custom setters & getters

@synthesize suit = _suit;

- (void)setSuit:(NSString *)suit
{
    // protect setter
    if ([[PlayingCard validSuits] containsObject:suit])
    {
        _suit = suit;
    }
}

- (NSString *)suit
{    
    // if _suit has never been set, return @"?", otherwise return the ivar
    return _suit ? _suit : @"?";
}

- (void)setRank:(NSUInteger)rank
{   
    // protect setter 
    if (rank <= [PlayingCard maxRank])
    {
        _rank = rank;
    }
}

#pragma mark - private class methods

+ (NSArray *)rankStrings
{    
    // returns an array with the ranks
    static NSArray *rankStrings = nil;
    
    // handle first time definition
    if (!rankStrings)
        rankStrings = @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
    
    return rankStrings;
}

#pragma mark - public class methods

+ (NSArray *)validSuits
{    
    // a C static has been used here, doing this is optional
    static NSArray *validSuits = nil;
    
    // handle first time definition
    if (!validSuits)
        validSuits = @[@"♥", @"♦", @"♠", @"♣"];
    
    return validSuits;
}

+ (NSUInteger)maxRank
{    
    return [self rankStrings].count-1;
}

#pragma mark - overridden super class methods

// note from Piazza : There is no 'override' keyword (or 'virtual' or 'sealed' or any other keyword that deals with subclassing and overrideability) in Objective-C
// Objective-C uses dynamic binding. That means that which message is being called is determined at runtime, rather than at compile time. When you send a message to an object, the object will reply to that message if a method by that name is defined for it. If it can't it will pass the message on to it's superclass implementation and so on. If the root super class cannot answer the message, an exception will occur.
//That also means, that there is no real concept of public or private methods in terms of accessibility. If you declare your init method only in the .m file, it only means that other classes do not know that you override the init method, but your objects will still respond to the init message with their own (private) init implementation and subclasses of your class will also use that overridden implementation unless they provide their own.

- (NSString *)contents
{
    // returns a string containing the rank & suit
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

// 'Card's matches only if the cards are exactly the same (that is to say, their contents @property values are equal).
// 'PlayingCard's should match if the 'suit' and/or 'rank' is the same -> override this method here in PlayingCard to do this.

// note : often a subclass's implementation of a method will call it's superclass's implementation by invoking super (e.g. [super match:...]), but PlayingCard has its own, standalone implementation of this method and thus does not need to call super's implementation

- (int)match:(NSArray *)otherCards
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    int score = 0;
    
    // only match a single other card (for now -> homework will be different)
    if (otherCards.count == 1)
    {
        NSLog(@"matching 2 cards");
        
        // let's get the card in the array (there will be only one card in the array if we got this far)
        // note : 'lastObject' is an NSArray method. It is just like [array objectAtIndex:array.count - 1], except that it will not crash if the array is empty. It will just return nil -> much more convenient!!!
        PlayingCard *otherCard = [otherCards lastObject];
        
        // matching the suit gives 4 times as many points for matching the suit (since there are only 3 cards that will match a given card's rank, but 12 which will match its suit)
        if([otherCard.suit isEqualToString:self.suit])
        {
            self.matched = YES;
            otherCard.matched = YES;
            score = 1;
        }
        else if (otherCard.rank == self.rank)
        {
            self.matched = YES;
            otherCard.matched = YES;
            score = 4;
        }
    }
    
    return score;
}

+ (MatchResults *)matchMultiplePlayingCards:(NSArray *)cards
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    MatchResults *matchResults = [[MatchResults alloc] init];
    
    for (NSString *suit in [PlayingCard validSuits])
    {
        int currentSuitMatches = 0;
        
        // now check all cards against the suit
        for (PlayingCard *aCard in cards)
        {
            if([aCard.suit isEqualToString:suit])
                currentSuitMatches++;
        }
        
        // if we have a suit match, we should set the match @property
        if (currentSuitMatches > 1)
        {
            NSLog(@"suit %@ was matched %d times", suit, currentSuitMatches);
            
            // describe the match & add it the the results object
            MatchDescription *description = [[MatchDescription alloc] init];
            description.matchType = kMATCH_TYPE_SUIT;
            description.matchedItem = suit;
            description.nbrOfCardsInMatch = currentSuitMatches;
            [matchResults addMatchResult:description];
            
            // mark the matched cards so the controller can handle the rest
            for (PlayingCard *aPlayingCard in cards)
            {
                if([aPlayingCard.suit isEqualToString:suit])
                    aPlayingCard.matched = YES;
            }
        }
    }
    
    // note the '<=', you want to 'include' the maxRank too!
    // note also that we start from rank '1' as '0' is considered an invalid rank
    for (NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank++)   // TBD : add 'minRank' method instead of starting from '1' ??
    {
        int currentRankMatches = 0;
        
        //        NSLog(@"matching rank %d", rank);
        
        // now check all cards against the suit
        for (PlayingCard *aCard in cards)
        {
            if(aCard.rank == rank)
                currentRankMatches++;
        }
        
        // if we have a suit match, we should set the match @property
        if (currentRankMatches > 1)
        {
            NSLog(@"rank %d was matched %d times", rank, currentRankMatches);
            
            // describe the match & add it the the results object            
            MatchDescription *description = [[MatchDescription alloc] init];
            description.matchType = kMATCH_TYPE_RANK;
            description.matchedItem = [NSString stringWithFormat:@"%D",rank];
            description.nbrOfCardsInMatch = currentRankMatches;
            [matchResults addMatchResult:description];
            
            // mark the matched cards so the controller can handle the rest
            for (PlayingCard *aPlayingCard in cards)
            {
                if(aPlayingCard.rank == rank)
                    aPlayingCard.matched = YES;
            }
        }
    }
    
    return matchResults;
}

@end
