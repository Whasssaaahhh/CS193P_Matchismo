//
//  MatchResults.h
//  Matchismo
//
//  Created by Ronny Webers on 23/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatchDescription.h"

// This class keeps an array of 'MatchDescription' items

@interface MatchResults : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *results;    // TBD : should this be a 'copy' ???

- (void)addMatchResult:(MatchDescription *)result;

@end
