//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Ronny Webers on 14/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

// our game lets you match among a certain number of cards, given a certain Deck to choose from
// -> create a designated initializer that initializes a newly allocated game with these 2 pieces of information
// important : NEVER call an initializer on a previously initialized object. In other words, calls to init methods are ALWAYS nested with alloc (e.g. [[MyClass alloc] init]
// important : how do we know which is the designated initializer ? -> documentation (see comment below) !!!

@interface CardMatchingGame : NSObject

// designated initializer
- (id)initWithCardCount:(NSUInteger)cardCount usingDeck:(Deck *)deck;

// obviously it must be possible to flip a card at a certain index
- (void)flipCardAtIndex:(NSUInteger)index;

// it must be possible to get a card so that for a given index it can be displayed by some UI somewhere
- (Card *)cardAtIndex:(NSUInteger)index;

@property (nonatomic,readonly) int score;       // no setter

@property (nonatomic,readonly) NSString *status;

@end

// note that noe of the above code has something to do with UI. It's up to the controller to interpret the Model into something presented to the user via a View
