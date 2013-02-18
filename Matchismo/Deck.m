//
//  Deck.m
//  Matchismo
//
//  Created by Ronny Webers on 11/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "Deck.h"

@interface Deck()

@property (strong, nonatomic) NSMutableArray *cards;

@end

@implementation Deck

//- (NSUInteger)numberOfCardsInDeck
//{
//    return [self.cards count];
//}


- (NSMutableArray *)cards
{
    // use the getter for lazy instantiation
    if (!_cards)
        _cards = [[NSMutableArray alloc] init];
    
    return _cards;
}

- (void)addCard:(Card *)card atTop:(BOOL)atTop
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (atTop)
    {
        [self.cards insertObject:card atIndex:0];
    }
    else
    {
        [self.cards addObject:card];
    }
}

- (Card *)drawRandomCard
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    Card *randomCard = nil;
    
    // check first if array is not empty (would chrash)
    if (self.cards.count)
    {
        // generate a valid random index
        unsigned index = arc4random() % self.cards.count;
        
        // get the card and remove it from the deck
        randomCard = self.cards[index];
        [self.cards removeObjectAtIndex:index];
    }
    
    return randomCard;
}

@end
