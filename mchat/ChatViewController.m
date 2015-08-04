//
//  ChatViewController.m
//  MChat
//
//  Created by Сергей Зинченко on 03.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatViewController.h"

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
//    static NSString *viewIdentifier = @"chatCell";
//    ChatTableCellView *cell = (ChatTableCellView *)[tblView makeViewWithIdentifier:viewIdentifier owner:self];
//    cell.chat = chatsToDisplay[row];
//    return cell;
    return nil;
}

@end
