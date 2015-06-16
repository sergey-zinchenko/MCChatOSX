//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)showProgressIndicator;
- (void)hideProgressIndicator;
@end

@implementation ViewController
{
    __weak IBOutlet NSTableView *tblView;
    __weak IBOutlet NSView *progressIndicatorHolderView;
    __weak IBOutlet NSProgressIndicator *progressIndicatorView;
    __weak IBOutlet NSTextField *progressIndicatorLabelView;
    NSMutableArray *companions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    companions = [[NSMutableArray alloc] init];
    [companions addObjectsFromArray:[MCChatClient sharedInstance].companions];
    [MCChatClient sharedInstance].deligate = self;
    [progressIndicatorView startAnimation:self];
    progressIndicatorHolderView.alphaValue = 0.8;
    progressIndicatorHolderView.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    progressIndicatorHolderView.layer.cornerRadius = 10;
    progressIndicatorHolderView.hidden = YES;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)showProgressIndicator
{
    progressIndicatorHolderView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptStartedNotifcation object:self userInfo:nil];
}

- (void)hideProgressIndicator
{
    progressIndicatorHolderView.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{@"successfully" : @YES}];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [companions removeAllObjects];
    [self showProgressIndicator];
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client
{
    [self hideProgressIndicator];
}

- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client
{
    [companions addObject:user];
    [tblView reloadData];
}

- (void)onUserDisconnected:(MCChatUser *)user
                 forClient:(MCChatClient *)client
{
    [companions removeObject:user];
    [tblView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [companions count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *viewIdentifier = @"companionCell";
    NSTableCellView *cell = [tblView makeViewWithIdentifier:viewIdentifier owner:self];
    [cell.textField setStringValue:((MCChatUser *)companions[row]).name];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
//    if (tblView.numberOfSelectedRows > 0) {
//        [self performSegueWithIdentifier:@"openchat" sender:self];
//        [tblView deselectRow:tblView.selectedRow];
//    }
}

@end
