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
- (void)setCompanionName:(NSString *)companionName;
- (void)updateUi;
@end

@implementation SimpleMessageTableCellView
{
     __weak IBOutlet NSTextField *messageTextField;
     __weak IBOutlet NSTextField *additionInfoField;
}

@synthesize date = _date, messageText = _messageText, companionName = _companionName;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)updateUi
{
    if (_messageText)
        messageTextField.stringValue = _messageText;
    NSString *dateString = nil;
    if (_date) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setTimeStyle:NSDateFormatterShortStyle];
        [format setDateStyle:NSDateFormatterMediumStyle];
        dateString = [format stringFromDate:_date];
    }
    if (dateString&&_companionName)
        additionInfoField.stringValue = [NSString stringWithFormat:@"%@ at %@", _companionName, dateString];
    else if (dateString)
        additionInfoField.stringValue = dateString;
    else if (_companionName)
        additionInfoField.stringValue = _companionName;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateUi];
}

- (void)setMessageText:(NSString *)messageText
{
    _messageText = messageText;
    [self updateUi];
}

- (void)setCompanionName:(NSString *)companionName
{
    _companionName = companionName;
    [self updateUi];
}


@end
