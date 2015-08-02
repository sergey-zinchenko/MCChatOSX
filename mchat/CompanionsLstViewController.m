//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "CompanionsLstViewController.h"
#import "CompanionTableCellView.h"
#import "NSArray+dif.h"
#import "MainWindowController.h"

@interface CompanionsLstViewController ()
- (void)playDingSound;
- (void)filterAndDispayCompanions;
- (IBAction)searchFieldAction:(NSSearchField *)sender;
- (void)startChatAction:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;
@end

@implementation CompanionsLstViewController
{
    __weak IBOutlet NSTableView *tblView;
    
    NSMutableArray *companions;
    NSArray *companionsToDisplay;
    AVAudioPlayer *player;
    NSPredicate *filterPredicate;
}

- (void)filterAndDispayCompanions
{
    NSArray *newFilteredArray = filterPredicate?[companions filteredArrayUsingPredicate:filterPredicate]:[companions copy];
    NSIndexSet *ins = nil, *del = nil;
    [newFilteredArray computeDeletions:&del insertions:&ins comparisonToInitialState:companionsToDisplay];
    companionsToDisplay = newFilteredArray;
    [tblView beginUpdates];
    [tblView removeRowsAtIndexes:del withAnimation:NSTableViewAnimationSlideRight];
    [tblView insertRowsAtIndexes:ins withAnimation:NSTableViewAnimationSlideLeft];
    [tblView endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    companions = [[NSMutableArray alloc] init];
    [companions addObjectsFromArray:[MCChatClient sharedInstance].companions];
    companionsToDisplay = [companions copy];
    [MCChatClient sharedInstance].deligate = self;
    [tblView reloadData];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [companions removeAllObjects];
    [self filterAndDispayCompanions];
}

-(void)onDisconnectOccurredWithException:(NSString *)exception
                               andReason:(NSString *)reason
                               forClient:(MCChatClient *)client
{
    [companions removeAllObjects];
    [self filterAndDispayCompanions];
}

- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client
{
    [companions addObject:user];
    [self filterAndDispayCompanions];
    [self playDingSound];
}

- (void)onUserDisconnected:(MCChatUser *)user
                 forClient:(MCChatClient *)client
{
    [companions removeObject:user];
    [self filterAndDispayCompanions];
}

- (void)onUserInfoChanged:(MCChatUser *)user
                forClient:(MCChatClient *)client
{
    [tblView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[companionsToDisplay indexOfObject:user]]
                       columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [companionsToDisplay count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *viewIdentifier = @"companionCell";
    CompanionTableCellView *cell = (CompanionTableCellView *)[tblView makeViewWithIdentifier:viewIdentifier owner:self];
    MCChatUser *companion = companionsToDisplay[row];
    [cell setName:companion.name];
    [cell setLocation:companion.location];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
//    if (tblView.numberOfSelectedRows > 0) {
//        NSArray *selectedUsers = [companionsToDisplay objectsAtIndexes:tblView.selectedRowIndexes];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUsersSelectionChangedNotification object:self userInfo:@{kSelectedUsersSet: selectedUsers}];
//    }

//    [[[NSApplication sharedApplication] menu] ]
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL sel = menuItem.action;
    if (sel == @selector(startChatAction:)) {
        return tblView.numberOfSelectedRows > 0;
    }
    return NO;
}

- (void)startChatAction:(id)sender
{
    if (tblView.numberOfSelectedRows > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStartChatClickedNotification object:self userInfo:@{kChatUsersArray:[companionsToDisplay objectsAtIndexes:tblView.selectedRowIndexes]}];
    }
}

- (void)playDingSound
{
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource:@"ding-sound"
                                    ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                           error:nil];
    [player play];
}

- (IBAction)searchFieldAction:(NSSearchField *)sender {
    NSString *attributeValue = [sender stringValue];
    filterPredicate = (attributeValue&&![attributeValue isEqualToString:@""])?[NSPredicate predicateWithFormat:@"(name contains[cd] %@) or (location contains[cd] %@)",attributeValue, attributeValue]:nil;
    [self filterAndDispayCompanions];
}


@end
