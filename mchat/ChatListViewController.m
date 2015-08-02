//
//  ChatListViewController.m
//  MChat
//
//  Created by Сергей Зинченко on 23.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatTableCellView.h"
#import "NSArray+dif.h"

@interface ChatListViewController ()
- (void)filterAndDispayChats;
- (IBAction)searchFieldAction:(NSSearchField *)sender;
- (void)onUserConnectedNotification:(NSNotification *)notif;
@end

@implementation ChatListViewController
{
    __weak IBOutlet NSTableView *tblView;
    
    NSMutableArray *chats;
    NSArray *chatsToDisplay;
    NSPredicate *filterPredicate;
}

- (void)filterAndDispayChats
{
    NSArray *newFilteredArray = filterPredicate?[chats filteredArrayUsingPredicate:filterPredicate]:[chats copy];
    NSIndexSet *ins = nil, *del = nil;
    [newFilteredArray computeDeletions:&del insertions:&ins comparisonToInitialState:chatsToDisplay];
    chatsToDisplay = newFilteredArray;
    [tblView beginUpdates];
    [tblView removeRowsAtIndexes:del withAnimation:NSTableViewAnimationSlideRight];
    [tblView insertRowsAtIndexes:ins withAnimation:NSTableViewAnimationSlideLeft];
    [tblView endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    chats = [[NSMutableArray alloc] init];
    [chats addObjectsFromArray:[MCChatClient sharedInstance].chats];
    chatsToDisplay = [chats copy];
    [MCChatClient sharedInstance].chatsDeligate = self;
    [tblView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserConnectedNotification:) name:kUserConnectedNotification object:[MCChatClient sharedInstance]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [chatsToDisplay count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *viewIdentifier = @"chatCell";
    ChatTableCellView *cell = (ChatTableCellView *)[tblView makeViewWithIdentifier:viewIdentifier owner:self];
    cell.chat = chatsToDisplay[row];
    return cell;
}


- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [chats removeAllObjects];
    [self filterAndDispayChats];
}

- (void)onDisconnectOccurredForClient:(MCChatClient *)client
{
    [chats removeAllObjects];
    [self filterAndDispayChats];
}

- (void)onChatStarted:(MCChatChat *)chat
            forClient:(MCChatClient *)client
{
    [chats addObject:chat];
    [self filterAndDispayChats];
}

- (void)onChatInvitationRecieved:(MCChatChat *)chat
                        fromUser:(MCChatUser *)user
                       forClient:(MCChatClient *)client
{
    [chats addObject:chat];
    [self filterAndDispayChats];
    //[self playDingSound];
}

- (void)onChatAccepted:(MCChatChat *)chat
             forClient:(MCChatClient *)client
{
    [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[chatsToDisplay indexOfObject:chat]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)onChatEnded:(MCChatChat *)chat
          forClient:(MCChatClient *)client
{
    [chats removeObject:chat];
    [self filterAndDispayChats];
}

- (void)onChatAccepted:(MCChatChat *)chat
           byCompanion:(MCChatUser *)companion
             forClient:(MCChatClient *)client
{
    [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[chatsToDisplay indexOfObject:chat]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)onChatDeclined:(MCChatChat *)chat
           byCompanion:(MCChatUser *)companion
             forClient:(MCChatClient *)client
{
    if ([chat.companions count] > 0)
        [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[chatsToDisplay indexOfObject:chat]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)onChatLeft:(MCChatChat *)chat
       byCompanion:(MCChatUser *)companion
         forClient:(MCChatClient *)client
{
//    if ([chat.companions count] >= 0)
        [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[chatsToDisplay indexOfObject:chat]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (IBAction)searchFieldAction:(NSSearchField *)sender
{
    NSString *attributeValue = [sender stringValue];
    filterPredicate = (attributeValue&&![attributeValue isEqualToString:@""])?[NSPredicate predicateWithFormat:@"theme contains[cd] %@",attributeValue, attributeValue]:nil;
    [self filterAndDispayChats];
}

-(void)onUserConnectedNotification:(NSNotification *)notif
{
    MCChatChat *publicChat = ((MCChatClient *)notif.object).publicChat;
    if (publicChat) {
        NSUInteger index = [chatsToDisplay indexOfObject:publicChat];
        if (index != NSNotFound)
            [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    
}

@end
