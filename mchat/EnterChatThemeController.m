//
//  EnterChatThemeController.m
//  MChat
//
//  Created by Сергей Зинченко on 04.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "EnterChatThemeController.h"
#import "MCChatChat.h"
#import "ChatWindowCoordinator.h"

@interface EnterChatThemeController ()
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@end

@implementation EnterChatThemeController
{
    __weak IBOutlet NSTextField *label;
    __weak IBOutlet NSTextField *themeField;
    __weak IBOutlet NSButton *openChatWidowCheckBox;
}

@synthesize users = _users;

- (void)viewWillAppear {
    NSString *userTemplate = ([self.users count] > 1)? @"users":@"user";
    [label setStringValue:[NSString stringWithFormat:@"You want to start chat with %ld %@....\nWhat is a theme of the discussion?", [self.users count], userTemplate]];
}

- (IBAction)okClicked:(id)sender
{
    MCChatChat *chat = [MCChatChat startChatWithCompanions:self.users
                              chatTheme:[themeField stringValue]];
    if (openChatWidowCheckBox.state == NSOnState)
        [[ChatWindowCoordinator sharedInstance] displayWindowForChat:chat];
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (IBAction)cancelClicked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

@end
