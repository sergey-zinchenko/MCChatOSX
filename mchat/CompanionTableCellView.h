//
//  CompanionTableCellView.h
//  mchat
//
//  Created by Сергей Зинченко on 18.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CompanionTableCellView : NSTableCellView

- (void)setLocation:(NSString *)location;
- (void)setName:(NSString *)name;

@end
