//
//  MatchResults.m
//  Matchismo
//
//  Created by Ronny Webers on 23/02/13.
//  Copyright (c) 2013 AM2 Consulting BVBA. All rights reserved.
//

#import "MatchResults.h"


@interface MatchResults ()

@property (strong, nonatomic, readwrite) NSMutableArray *results;

@end

@implementation MatchResults

- (NSMutableArray *)results
{
    // use the getter for lazy instantiation
    if (!_results)
        _results = [[NSMutableArray alloc] init];
    
    return _results;
}

- (void)addMatchResult:(MatchDescription *)result
{
    [self.results addObject:result];
    NSLog(@"#items in result array : %d", self.results.count);
}


@end
