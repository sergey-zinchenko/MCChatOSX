//
//  NSArray+dif.h
//  MChat
//
//  Created by Сергей Зинченко on 30.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(dif)
- (void)computeDeletions:(NSIndexSet **)deletions
              insertions:(NSIndexSet **)insertions
comparisonToInitialState:(NSArray *)initialArray;
@end
