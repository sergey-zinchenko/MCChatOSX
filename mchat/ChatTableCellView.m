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
    NSUInteger acceptedCount = [_chat.acceptedCompanions count];
    NSUInteger pendingCount = [_chat.companions count] - acceptedCount;
    NSColor *textColor;
    if (_chat.state == MCChatChatStateAccepted) {
        textColor = [NSColor textColor];
    } else {
        textColor = [NSColor redColor];
    }
    chatThemeField.textColor = textColor;
    chatInfoField.textColor = textColor;
    NSString *companionsString = acceptedCount > 1?@"companions":@"companion";
    chatThemeField.stringValue = _chat.theme;
    chatInfoField.stringValue = pendingCount > 0?[NSString stringWithFormat:@"%ld %@ accepted already and %ld still pending", (unsigned long)acceptedCount, companionsString, (unsigned long)pendingCount]:[NSString stringWithFormat:@"%ld %@ accepted already", (unsigned long)acceptedCount, companionsString];
}

- (IBAction)onTopButtonClicked:(id)sender
{
    
}

- (IBAction)onBottomButtonClicked:(id)sender
{
    
}

@end
