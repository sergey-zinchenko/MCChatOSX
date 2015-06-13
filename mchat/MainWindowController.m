//
//  MainWindowController.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MainWindowController.h"
#import "ViewController.h"
#import "ConnectItem.h"

@interface MainWindowController ()
- (void)connectionAttemptStartedNotifcation:(NSNotification*)notif;
- (void)connectionAttemptEndedNotifcation:(NSNotification*)notif;
@end

@implementation MainWindowController
{
    IBOutlet ConnectItem *connectItem;
}

- (void)connectionAttemptStartedNotifcation:(NSNotification*)notif
{
    connectItem.connectingNow = YES;
}

- (void)connectionAttemptEndedNotifcation:(NSNotification*)notif
{
    connectItem.connectingNow = NO;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.titleVisibility = NSWindowTitleHidden;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptStartedNotifcation:) name:kConnectionAttemptStartedNotifcation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptEndedNotifcation:) name:kConnectionAttemptEndedNotifcation object:nil];
    connectItem.connectingNow = NO;
}

@end
