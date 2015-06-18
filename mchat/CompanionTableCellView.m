//
//  CompanionTableCellView.m
//  mchat
//
//  Created by Сергей Зинченко on 18.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "CompanionTableCellView.h"

@implementation CompanionTableCellView
{
    __weak IBOutlet NSTextField *userNameField;
    __weak IBOutlet NSTextField *locationField;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setLocation:(NSString *)location
{
    [locationField setStringValue:location];
}

- (void)setName:(NSString *)name
{
    [userNameField setStringValue:name];
}

@end
