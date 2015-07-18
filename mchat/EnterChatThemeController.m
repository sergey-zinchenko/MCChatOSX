//
//  EnterChatThemeController.m
//  MChat
//
//  Created by Сергей Зинченко on 04.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "EnterChatThemeController.h"

@interface EnterChatThemeController ()
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@end

@implementation EnterChatThemeController
{
   __weak IBOutlet NSTextField *label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [label setStringValue:[NSString stringWithFormat:@"You want to start chat with %ld users....\nWhat is a theme of the discussion?", [self.users count]]];
}

- (IBAction)okClicked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (IBAction)cancelClicked:(id)sender
{
    [self.view.window.sheetParent endSheet:self.view.window];
}

@end
