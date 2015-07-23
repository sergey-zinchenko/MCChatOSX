//
//  ChatListViewController.m
//  MChat
//
//  Created by Сергей Зинченко on 23.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatListViewController.h"

@interface ChatListViewController ()

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MCChatClient sharedInstance].chatsDeligate = self;
    // Do view setup here.
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client
{
    
}

- (void)onDisconnectOccurredForClient:(MCChatClient *)client
{
    
}

- (void)onChatStarted:(MCChatChat *)chat
            forClient:(MCChatClient *)client
{
    
}

- (void)onChatInvitationRecieved:(MCChatChat *)chat
                        fromUser:(MCChatUser *)user
                       forClient:(MCChatClient *)client
{
    
}

- (void)onChatAccepted:(MCChatChat *)chat
             forClient:(MCChatClient *)client
{
    
}

- (void)onChatDeclined:(MCChatChat *)chat
             forClient:(MCChatClient *)client
{
    
}

- (void)onChatLeft:(MCChatChat *)chat
         forClient:(MCChatClient *)client
{
    
}

@end
