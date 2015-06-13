//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MCChatClient sharedInstance].deligate = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                ForClient:(MCChatClient *)client
{
    
}

@end
