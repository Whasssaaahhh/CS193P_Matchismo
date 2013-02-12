//
//  Deck.h
//  Matchismo
//
//  Created by Ronny Webers on 11/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

@property (nonatomic, readonly) NSUInteger numberOfCardsInDeck;

- (void)addCard:(Card *)card atTop:(BOOL)atTop;
- (Card *)drawRandomCard;

@end
