//
//  AcceptChatViewController.m
//  MChat
//
//  Created by Сергей Зинченко on 29.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "AcceptChatViewController.h"

@interface AcceptChatViewController ()

- (IBAction)onAcceptCliecked:(id)sender;
- (IBAction)onDeclineCliecked:(id)sender;
- (void)onChatCompanionsChanged;
- (void)clearChatAndClose;
- (void)setChat:(MCChatChat *)chat;
- (void)setChatInitiator:(MCChatUser *)chatInitiator;
- (void)updateUi;
@end

@implementation AcceptChatViewController
{
    __weak IBOutlet NSButton *acceptButton;
    __weak IBOutlet NSButton *declineButton;
    __weak IBOutlet NSTextField *messageField;
    __weak IBOutlet NSButton *openChatWidowCheckBox;
}

@synthesize chat = _chat, chatInitiator = _chatInitiator;

- (void)updateUi
{
    if (!self.chat&&self.chatInitiator)
        return;
    [messageField setStringValue:[NSString stringWithFormat:@"%@ wants to start chat with you. %lu companions accepted discussion already. \nTheme is \"%@\". Do you accept?", self.chatInitiator.name, (unsigned long)[self.chat.acceptedCompanions count], self.chat.theme]];
}

- (void)setChat:(MCChatChat *)chat
{
    _chat = chat;
    _chat.delegate = self;
    [self updateUi];
}

- (void)setChatInitiator:(MCChatUser *)chatInitiator
{
    _chatInitiator = chatInitiator;
    [self updateUi];
}

- (void)clearChatAndClose
{
    _chat.delegate = nil;
    _chat = nil;
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self updateUi];
}

- (IBAction)onAcceptCliecked:(id)sender
{
    [self clearChatAndClose];
}

- (IBAction)onDeclineCliecked:(id)sender
{
    [self clearChatAndClose];
}

- (void)onChatCompanionsChanged
{
    if ([self.chat.companions count] == 0) {
        [self clearChatAndClose];
    } else {
        [self updateUi];
    }
}

- (void)onCompanion:(MCChatUser *)companion
       declinedChat:(MCChatChat *)chat
{
    [self onChatCompanionsChanged];
}

- (void)onCompanion:(MCChatUser *)companion
           leftChat:(MCChatChat *)chat
{
    [self onChatCompanionsChanged];
}

@end
