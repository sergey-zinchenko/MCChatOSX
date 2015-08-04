//
//  SimpleMessageTableCellView.m
//  MChat
//
//  Created by Сергей Зинченко on 04.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "SimpleMessageTableCellView.h"

@interface SimpleMessageTableCellView ()
- (void)setDate:(NSDate *)date;
- (void)setMessageText:(NSString *)messageText;
@end

@implementation SimpleMessageTableCellView
{
     __weak IBOutlet NSTextField *messageTextField;
     __weak IBOutlet NSTextField *dateField;
}

@synthesize date = _date, messageText = _messageText;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeStyle:NSDateFormatterShortStyle];
    [format setDateStyle:NSDateFormatterMediumStyle];
    dateField.stringValue = [format stringFromDate:date];
}

- (void)setMessageText:(NSString *)messageText
{
    messageTextField.stringValue = messageText;
}

@end
