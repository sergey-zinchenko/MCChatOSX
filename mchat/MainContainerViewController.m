//
//  MainContainerViewController.m
//  mchat
//
//  Created by Сергей Зинченко on 21.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MainContainerViewController.h"
#import "MCChatClient.h"

@interface MainContainerViewController ()
- (void)showProgressIndicator;
- (void)hideProgressIndicator;
- (void)onConnectionAttemptStartedNotification:(NSNotification *)n;
- (void)onConnectionAttemptEndedNotification:(NSNotification *)n;
@end

@implementation MainContainerViewController
{
    __weak IBOutlet NSView *progressIndicatorHolderView;
    __weak IBOutlet NSProgressIndicator *progressIndicatorView;
    __weak IBOutlet NSTextField *progressIndicatorLabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MCChatClient sharedInstance].useNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionAttemptStartedNotification:) name:kConnectionAttemptStartedNotifcation object:[MCChatClient sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionAttemptEndedNotification:) name:kConnectionAttemptEndedNotifcation object:[MCChatClient sharedInstance]];
    [progressIndicatorView startAnimation:self];
    progressIndicatorHolderView.alphaValue = 0.8;
    progressIndicatorHolderView.layer.backgroundColor = [[NSColor controlColor] CGColor];
    progressIndicatorHolderView.layer.cornerRadius = 10;
    progressIndicatorHolderView.layer.borderColor = [[NSColor controlDarkShadowColor] CGColor];
    progressIndicatorHolderView.layer.borderWidth = 1;
    progressIndicatorHolderView.hidden = YES;
}

- (void)showProgressIndicator
{
    progressIndicatorHolderView.hidden = NO;
}

- (void)hideProgressIndicator
{
    progressIndicatorHolderView.hidden = YES;
}

- (void)onConnectionAttemptStartedNotification:(NSNotification *)n
{
    [self showProgressIndicator];
}

- (void)onConnectionAttemptEndedNotification:(NSNotification *)n
{
    [self hideProgressIndicator];
}

@end
