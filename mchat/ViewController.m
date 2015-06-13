//
//  ViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)showProgressIndicator;
- (void)hideProgressIndicator;
@end

@implementation ViewController
{
    IBOutlet NSView *progressIndicatorHolderView;
    IBOutlet NSProgressIndicator *progressIndicatorView;
    IBOutlet NSTextField *progressIndicatorLabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MCChatClient sharedInstance].deligate = self;
    [progressIndicatorView startAnimation:self];
    progressIndicatorHolderView.alphaValue = 0.8;
    progressIndicatorHolderView.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    progressIndicatorHolderView.layer.cornerRadius = 10;
    progressIndicatorHolderView.hidden = YES;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)showProgressIndicator
{
    progressIndicatorHolderView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptStartedNotifcation object:self userInfo:nil];
}

- (void)hideProgressIndicator
{
    progressIndicatorHolderView.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{@"successfully" : @YES}];
}

- (void)onConnectAttemptStartedForClient:(MCChatClient *)client
{
    [self showProgressIndicator];
}

- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client
{
    [self hideProgressIndicator];
}

- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client
{
    
}

- (void)onUserDisconnected:(MCChatUser *)user
                 forClient:(MCChatClient *)client
{
    
}

@end
