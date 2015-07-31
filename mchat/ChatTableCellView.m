//
//  ChatTableCellView.m
//  MChat
//
//  Created by Сергей Зинченко on 31.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatTableCellView.h"

@interface ChatTableCellView ()
- (void)setChat:(MCChatChat *)chat;
- (void)updateUi;
- (IBAction)onTopButtonClicked:(id)sender;
- (IBAction)onBottomButtonClicked:(id)sender;
@end

@implementation ChatTableCellView
{
    __weak IBOutlet NSTextField *chatThemeField;
    __weak IBOutlet NSTextField *chatInfoField;
    __weak IBOutlet NSButton *topButton;
    __weak IBOutlet NSButton *bottomButton;
}

@synthesize chat = _chat;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setChat:(MCChatChat *)chat
{
    _chat = chat;
    [self updateUi];
}

- (void)updateUi
{
    if (!_chat)
        return;
    NSUInteger count = [_chat.acceptedCompanions count];
    chatThemeField.textColor = [NSColor disabledControlTextColor];
    chatInfoField.textColor = [NSColor disabledControlTextColor];
    NSString *companionsString = count > 1?@"companions":@"companion";
    chatThemeField.stringValue = _chat.theme;
    chatInfoField.stringValue = [NSString stringWithFormat:@"%ld %@ accepted already", (unsigned long)count, companionsString];

}

- (IBAction)onTopButtonClicked:(id)sender
{
    
}

- (IBAction)onBottomButtonClicked:(id)sender
{
    
}

@end
