//
//  Card.m
//  Matchismo
//
//  Created by Ronny Webers on 11/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "Card.h"

@implementation Card

- (int)match:(NSArray *)otherCards
{
    NSLog(@"-- %@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    int score = 0;
    
    for (Card *card in otherCards)
    {
        // Card matches only if the cards are exactly the same (that is to say, their contents @property values are equal). PlayingCards should match if the 'suit' and/or 'rank' is the same -> override this method in PlayingCard to do this.
        if ([card.contents isEqualToString:self.contents])
        {
            self.matched = YES;
            card.matched = YES;
            score = 1;
        }
    }
    
    return score;
}

@end
