//
//  MatchResult.h
//  Matchismo
//
//  Created by Ronny Webers on 23/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { kMATCH_TYPE_NONE = 0, kMATCH_TYPE_SUIT, kMATCH_TYPE_RANK } eMATCH_TYPES;

@interface MatchDescription : NSObject

@property (nonatomic) eMATCH_TYPES matchType;               // kMATCH_TYPE_SUIT, kMATCH_TYPRE_RANK (could be extended to 'three of a kind', 'straight, ...)
@property (nonatomic) NSUInteger nbrOfCardsInMatch;         // 2, 3, ...
@property (strong, nonatomic) NSString *matchedItem;        // @"♥", @"♦", @"A", @"2", ... (suit or rank)

@end
