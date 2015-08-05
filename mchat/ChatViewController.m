//
//  ChatViewController.m
//  MChat
//
//  Created by Сергей Зинченко on 03.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatViewController.h"
#import "SimpleMessageTableCellView.h"
#import "MCChatUser.h"
#import "MCChatClient.h"
#import "ChatWindowCoordinator.h"
#import "SoundEffects.h"

#define kMessageText @"kMessageText"
#define kDate @"kDate"
#define kCompanionName @"kCompanionName"

@interface ChatViewController ()
- (void)setChat:(MCChatChat *)chat;
- (void)updateTableView;
- (IBAction)messageFileldAction:(id)sender;
@end

@implementation ChatViewController
{
    __weak IBOutlet NSTextField *messageField;
    __weak IBOutlet NSTableView *tblView;
    NSMutableArray *chatEvents;
}

@synthesize chat = _chat;

- (void)viewDidLoad {
    [super viewDidLoad];
    chatEvents = [NSMutableArray array];
}

- (void)setChat:(MCChatChat *)chat
{
    _chat = chat;
    _chat.delegate = self;
    self.title = _chat.theme;
}

- (IBAction)messageFileldAction:(id)sender
{
    if (_chat.state == MCChatChatStateAccepted) {
        [_chat sendSimpleMessage:messageField.stringValue];
    }
    messageField.stringValue = @"";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [chatEvents count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *simpleIncomeViewIdentifier = @"simpleMessageCell";
    NSDictionary *event = chatEvents[row];
    SimpleMessageTableCellView *cell = (SimpleMessageTableCellView *)[tblView makeViewWithIdentifier:simpleIncomeViewIdentifier owner:self];
    cell.date = event[kDate];
    cell.messageText = event[kMessageText];
    cell.companionName = event[kCompanionName];
    return cell;
}

-(void)onSimpleMessageRecieved:(NSString *)message fromCompanion:(MCChatUser *)companion fromChat:(MCChatChat *)chat
{
    [chatEvents addObject:@{kMessageText: message, kCompanionName: companion.name,  kDate: [NSDate date]}];
    [self updateTableView];
}

-(void)onSimpleMessageSent:(NSString *)message fromChat:(MCChatChat *)chat
{
    [chatEvents addObject:@{kMessageText: message, kCompanionName: chat.client.myName , kDate: [NSDate date]}];
    [self updateTableView];
}

-(void)onCompanion:(MCChatUser *)companion acceptedChat:(MCChatChat *)chat
{
    [chatEvents addObject:@{kMessageText: @"Accepted chat", kCompanionName: companion.name , kDate: [NSDate date]}];
    [self updateTableView];
}

-(void)onCompanion:(MCChatUser *)companion declinedChat:(MCChatChat *)chat
{
    [chatEvents addObject:@{kMessageText: @"Declined chat", kCompanionName: companion.name , kDate: [NSDate date]}];
    [self updateTableView];
}

-(void)onCompanion:(MCChatUser *)companion leftChat:(MCChatChat *)chat
{
    [chatEvents addObject:@{kMessageText: @"Left chat", kCompanionName: companion.name, kDate: [NSDate date]}];
    [self updateTableView];
}

-(void)onChatEnded:(MCChatChat *)chat
{
    if (self.view.window.visible&&!self.view.window.miniaturized) {
        [chatEvents addObject:@{kMessageText: @"Chat ended", kDate: [NSDate date]}];
        [self updateTableView];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSInformationalAlertStyle;
        alert.messageText = @"This discussion is no longer active";
        alert.informativeText = @"Do you want to close this window?";
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            switch (returnCode) {
                case NSAlertFirstButtonReturn:
                    [[ChatWindowCoordinator sharedInstance] closeWindowForChat:chat];
                    break;
                case NSAlertSecondButtonReturn:
                    break;
                default:
                    break;
            }
        }];
    } else {
        [[ChatWindowCoordinator sharedInstance] closeWindowForChat:chat];
    }
}

- (void)updateTableView
{
    [tblView beginUpdates];
    [tblView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[tblView numberOfRows]] withAnimation:NSTableViewAnimationEffectNone];
    [tblView endUpdates];
    NSInteger numberOfRows = [tblView numberOfRows];
    if (numberOfRows > 0)
        [tblView scrollRowToVisible:numberOfRows - 1];
}

@end
