//
//  EnterYourNameController.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "EnterYourNameController.h"
#import "MCChatClient.h"

@interface EnterYourNameController ()
- (IBAction)okClicked:(id)sender;
@end

@implementation EnterYourNameController
{
    IBOutlet  NSTextField *nameTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)okClicked:(id)sender
{
    MCChatClient *cli = [MCChatClient sharedInstance];
    cli.myName = [nameTextField stringValue];
    [self.view.window close];
}

@end
