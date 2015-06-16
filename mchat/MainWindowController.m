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
    __weak IBOutlet ConnectItem *connectItem;
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
//    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
//    closeButton.enabled = YES;
    self.window.delegate = self;
    self.window.titleVisibility = NSWindowTitleHidden;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptStartedNotifcation:) name:kConnectionAttemptStartedNotifcation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptEndedNotifcation:) name:kConnectionAttemptEndedNotifcation object:nil];
    connectItem.connectingNow = NO;
}

- (BOOL)windowShouldClose:(id)sender
{
    [self.window miniaturize:self];
    return NO;
}

@end
