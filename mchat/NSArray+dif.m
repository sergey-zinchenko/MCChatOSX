//
//  NSArray+dif.m
//  MChat
//
//  Created by Сергей Зинченко on 30.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "NSArray+dif.h"

@implementation NSArray(dif)

- (void)computeDeletions:(NSIndexSet **)deletions
              insertions:(NSIndexSet **)insertions
comparisonToInitialState:(NSArray *)initialArray
{
    *insertions = [[NSMutableIndexSet alloc] init];
    *deletions = [[NSMutableIndexSet alloc] init];
    
    for (NSUInteger i = 0; i < [initialArray count]; i++)
        if ([self indexOfObject:initialArray[i]] == NSNotFound)
            [(NSMutableIndexSet *)*deletions addIndex:i];
    
    NSMutableArray *initialArrayWithDeletions = [initialArray mutableCopy];
    [initialArrayWithDeletions removeObjectsAtIndexes:*deletions];

    for (NSUInteger i = 0; i < [self count]; i++)
        if ([initialArrayWithDeletions indexOfObject:self[i]] == NSNotFound)
            [(NSMutableIndexSet *)*insertions addIndex:i];
    
}

@end
