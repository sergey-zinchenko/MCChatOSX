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

#define kMessageText @"kMessageText"
#define kIncome @"kIncome"
#define kDate @"kDate"

@interface ChatViewController ()
- (void)setChat:(MCChatChat *)chat;
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
    [_chat sendSimpleMessage:messageField.stringValue];
    messageField.stringValue = @"";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [chatEvents count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *simpleIncomeViewIdentifier = @"simpleIncomeMessageCell";
    static NSString *simpleOutcomeViewIdentifier = @"simpleOutcomeMessageCell";
    
    NSDictionary *event = chatEvents[row];
    SimpleMessageTableCellView *cell = (SimpleMessageTableCellView *)[tblView makeViewWithIdentifier:event[kIncome]?simpleIncomeViewIdentifier:simpleOutcomeViewIdentifier owner:self];
    cell.date = event[kDate];
    cell.messageText = event[kMessageText];
    return cell;
}

-(void)onSimpleMessageRecieved:(NSString *)message fromCompanion:(MCChatUser *)companion fromChat:(MCChatChat *)chat
{
    [tblView beginUpdates];
    [chatEvents addObject:@{kIncome:@YES, kMessageText:[NSString stringWithFormat:@"%@ > %@", companion.name, message], kDate: [NSDate date]}];
    [tblView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[chatEvents count]] withAnimation:NSTableViewAnimationSlideRight];
    [tblView endUpdates];
}

-(void)onSimpleMessageSent:(NSString *)message fromChat:(MCChatChat *)chat
{
    [tblView beginUpdates];
    [chatEvents addObject:@{kMessageText:[NSString stringWithFormat:@"%@ > %@", chat.client.myName , message], kDate: [NSDate date]}];
    [tblView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[chatEvents count]] withAnimation:NSTableViewAnimationSlideLeft];
    [tblView endUpdates];
}

@end
