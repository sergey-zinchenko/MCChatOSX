//
//  EnterChatThemeController.m
//  MChat
//
//  Created by Сергей Зинченко on 04.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "EnterChatThemeController.h"
#import "MCChatChat.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    NSString *userTemplate = ([self.users count] > 1)? @"users":@"user";
        
    [label setStringValue:[NSString stringWithFormat:@"You want to start chat with %ld %@....\nWhat is a theme of the discussion?", [self.users count], userTemplate]];
}

- (IBAction)okClicked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
    [MCChatChat startChatWithCompanions:self.users
                              chatTheme:[themeField stringValue]];
}

- (IBAction)cancelClicked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

@end
