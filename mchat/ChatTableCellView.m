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
    
}

- (IBAction)onTopButtonClicked:(id)sender
{
    
}

- (IBAction)onBottomButtonClicked:(id)sender
{
    
}

@end
