//
//  PlayingCardDeck.m
//  Matchismo
//
//  Created by Ronny Webers on 12/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

- (id)init
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self = [super init];
    
    if (self)
    {
        // creat the deck of PlayingCards
        for (NSString *suit in [PlayingCard validSuits])
        {
            for (NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank++)
            {
                PlayingCard *card = [[PlayingCard alloc] init];
                card.rank = rank;
                card.suit = suit;
//                NSLog(@"Adding card %@ to deck", card.contents);
                [self addCard:card atTop:YES];
            }
        }
 //       NSLog(@"Created a PlayingCardDeck with %d cards", self.cards.count); -> no access to self.cards !!! ??? TBD
    }
    
    return self;
}

@end
