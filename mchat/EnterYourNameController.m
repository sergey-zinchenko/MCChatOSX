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
- (IBAction)cancelClicked:(id)sender;
@end

@implementation EnterYourNameController
{
    __weak IBOutlet  NSTextField *nameTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)okClicked:(id)sender
{
    MCChatClient *cli = [MCChatClient sharedInstance];
    cli.myName = [nameTextField stringValue];
    [self dismissController:self];
}

- (IBAction)cancelClicked:(id)sender
{
    [self dismissController:self];
}

@end
