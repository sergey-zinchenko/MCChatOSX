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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
