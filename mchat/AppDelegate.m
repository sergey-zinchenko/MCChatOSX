//
//  AppDelegate.m
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "MCChatClient.h"
#import "UserNotificationCoordinator.h"

@interface AppDelegate ()
- (void)connectAction:(id)sender;
- (void)disconnectAction:(id)sender;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [UserNotificationCoordinator sharedInstance];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL theAction = [menuItem action];
    if (theAction == @selector(connectAction:)) {
        return [MCChatClient sharedInstance].status == MCChatCoreNotConnected;
    } else if (theAction == @selector(disconnectAction:)) {
        return [MCChatClient sharedInstance].status != MCChatCoreNotConnected;
    }
    return NO;
}

- (void)disconnectAction:(id)sender
{
    [[MCChatClient sharedInstance] disconnect];
}

- (void)connectAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectMenuClickedNotification object:nil];
}

@end
