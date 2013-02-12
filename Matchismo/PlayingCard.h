//
//  PlayingCard.h
//  Matchismo
//
//  Created by Ronny Webers on 12/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

// class methods, don't need an instance to operate
+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;

@end
