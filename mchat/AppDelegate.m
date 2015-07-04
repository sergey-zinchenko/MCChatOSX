//
//  AppDelegate.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()
- (IBAction)onConnectMenuClicked:(id)sender;
- (IBAction)onStartChatCliecked:(id)sender;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)onConnectMenuClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectMenuClickedNotification object:nil];
}

- (IBAction)onStartChatCliecked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartChatClickedNotification object:nil];
}

@end
