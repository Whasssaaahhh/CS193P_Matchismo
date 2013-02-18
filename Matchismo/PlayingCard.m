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
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // protect setter
    if ([[PlayingCard validSuits] containsObject:suit])
    {
        _suit = suit;
    }
}

- (NSString *)suit
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // if _suit has never been set, return @"?", otherwise return the ivar
    return _suit ? _suit : @"?";
}

- (void)setRank:(NSUInteger)rank
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // protect setter 
    if (rank <= [PlayingCard maxRank])
    {
        _rank = rank;
    }
}

#pragma mark - private class methods

+ (NSArray *)rankStrings
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
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
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // a C static has been used here, doing this is optional
    static NSArray *validSuits = nil;
    
    // handle first time definition
    if (!validSuits)
        validSuits = @[@"♥", @"♦", @"♠", @"♣"];
    
    return validSuits;
}

+ (NSUInteger)maxRank
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    return [self rankStrings].count-1;
}

#pragma mark - overridden super class methods

// note from Piazza : There is no 'override' keyword (or 'virtual' or 'sealed' or any other keyword that deals with subclassing and overrideability) in Objective-C
// Objective-C uses dynamic binding. That means that which message is being called is determined at runtime, rather than at compile time. When you send a message to an object, the object will reply to that message if a method by that name is defined for it. If it can't it will pass the message on to it's superclass implementation and so on. If the root super class cannot answer the message, an exception will occur.
//That also means, that there is no real concept of public or private methods in terms of accessibility. If you declare your init method only in the .m file, it only means that other classes do not know that you override the init method, but your objects will still respond to the init message with their own (private) init implementation and subclasses of your class will also use that overridden implementation unless they provide their own.

- (NSString *)contents
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // returns a string containing the rank & suit
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

#pragma mark - overridden superclass methods

// 'Card's matches only if the cards are exactly the same (that is to say, their contents @property values are equal).
// 'PlayingCard's should match if the 'suit' and/or 'rank' is the same -> override this method here in PlayingCard to do this.

// note : often a subclass's implementation of a method will call it's superclass's implementation by invoking super (e.g. [super match:...]), but PlayingCard has its own, standalone implementation of this method and thus does not need to call super's implementation

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    
    // only match a single other card (for now -> homework will be different)
    if (otherCards.count == 1)
    {
        // let's get the card in the array (there will be only one card in the array if we got this far)
        // note : 'lastObject' is an NSArray method. It is just like [array objectAtIndex:array.count - 1], except that it will not crash if the array is empty. It will just return nil -> much more convenient!!!
        PlayingCard *otherCard = [otherCards lastObject];
        
        // matching the suit gives 4 times as many points for matching the suit (since there are only 3 cards that will match a given card's rank, but 12 which will match its suit)
        if([otherCard.suit isEqualToString:self.suit])
        {
            score = 1;
        }
        else if (otherCard.rank == self.rank)
        {
            score = 4;
        }
    }
    
    return score;
}

@end
