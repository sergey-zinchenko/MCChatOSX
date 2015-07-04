//
//  MainWindowController.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MainWindowController.h"
#import "MCChatClient.h"


@interface MainWindowController ()
- (void)connectMenuClickedNotification:(NSNotification *)notif;
- (void)connectionAttemptEndedNotification:(NSNotification *)notif;
- (void)startChatMenuClickedNotification:(NSNotification *)notif;
- (void)connectAction:(id)sender;

@end

@implementation MainWindowController
{
    NSWindow *nameSheetWindow, *themeSheetWindow;
    LocationMonitor *locationMonitor;
}

- (void)connectMenuClickedNotification:(NSNotification*)notif
{
    
}

- (void)startChatMenuClickedNotification:(NSNotification *)notif
{
    if (!(nameSheetWindow||themeSheetWindow)) {
        static NSString *storyBoardName = @"Main";
        static NSString *viewControllerIdentifier = @"EnterThemeController";
        NSStoryboard *mainStoryBoard = [NSStoryboard storyboardWithName:storyBoardName
                                                                 bundle:nil];
        NSViewController *enterThemeViewController = [mainStoryBoard instantiateControllerWithIdentifier:viewControllerIdentifier];
        themeSheetWindow = [NSWindow windowWithContentViewController:enterThemeViewController];
        themeSheetWindow.releasedWhenClosed = YES;
        [self.window beginSheet:themeSheetWindow completionHandler:^(NSModalResponse returnCode) {
            [themeSheetWindow close];
            themeSheetWindow = nil;
        }];
    }
}

- (void)connectionAttemptEndedNotification:(NSNotification *)notif
{
    if ([notif.userInfo[kSuccessFlag] boolValue]) {
        @try {
            [locationMonitor start];
        }
        @catch (NSException *exception) {

        }
    }
}


- (void)windowDidLoad {
    [super windowDidLoad];
    //    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    //    closeButton.enabled = YES;
    self.window.delegate = self;
    //self.window.titleVisibility = NSWindowTitleHidden;
    locationMonitor = [[LocationMonitor alloc] init];
    locationMonitor.delegate = self;
    [MCChatClient sharedInstance].useNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectMenuClickedNotification:) name:kConnectMenuClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startChatMenuClickedNotification:) name:kStartChatClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptEndedNotification:) name:kConnectionAttemptEndedNotifcation object:[MCChatClient sharedInstance]];
}

- (BOOL)windowShouldClose:(id)sender
{
    [self.window miniaturize:self];
    return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL theAction = [menuItem action];
    if (theAction == @selector(connectAction:)) {
        return [MCChatClient sharedInstance].status == MCChatCoreNotConnected;
    }
    return NO;
}

- (void)connectAction:(id)sender
{
    if (!(nameSheetWindow||themeSheetWindow)) {
        static NSString *storyBoardName = @"Main";
        static NSString *viewControllerIdentifier = @"EnterNameController";
        NSStoryboard *mainStoryBoard = [NSStoryboard storyboardWithName:storyBoardName
                                                                 bundle:nil];
        NSViewController *enterNameViewController = [mainStoryBoard instantiateControllerWithIdentifier:viewControllerIdentifier];
        nameSheetWindow = [NSWindow windowWithContentViewController:enterNameViewController];
        nameSheetWindow.releasedWhenClosed = YES;
        [self.window beginSheet:nameSheetWindow completionHandler:^(NSModalResponse returnCode) {
            [nameSheetWindow close];
            nameSheetWindow = nil;
        }];
    }
}

- (void)locationDidChangedTo:(NSString *)locationString
{
    [[MCChatClient sharedInstance] updateMyLocation:locationString];
}

@end
