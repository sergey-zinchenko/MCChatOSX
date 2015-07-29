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
@end

@implementation AcceptChatViewController
{
    __weak IBOutlet NSButton *acceptButton;
    __weak IBOutlet NSButton *declineButton;
    __weak IBOutlet NSTextField *messageField;
    __weak IBOutlet NSButton *openChatWidowCheckBox;
}

@synthesize chat = _chat, chatInitiator = _chatInitiator;

- (void)setChat:(MCChatChat *)chat
{
    _chat = chat;
    _chat.delegate = self;
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
}

- (IBAction)onAcceptCliecked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (IBAction)onDeclineCliecked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (void)onChatCompanionsChanged
{
    if ([self.chat.companions count] == 0) {
        [self clearChatAndClose];
    } else {
        
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
