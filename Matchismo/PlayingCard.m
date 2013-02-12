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

- (NSString *)contents
{
    // returns a string containing the rank & suit
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

@end
