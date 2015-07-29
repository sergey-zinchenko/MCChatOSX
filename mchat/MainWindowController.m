//
//  MainWindowController.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MainWindowController.h"
#import "MCChatClient.h"
#import "EnterChatThemeController.h"


@interface MainWindowController ()
- (void)connectMenuClickedNotification:(NSNotification *)notif;
- (void)connectionAttemptEndedNotification:(NSNotification *)notif;
- (void)startChatMenuClickedNotification:(NSNotification *)notif;
- (void)chatInvitationrecievedNotification:(NSNotification *)notif;
@end

@implementation MainWindowController
{
    NSWindow *nameSheetWindow, *themeSheetWindow;
    LocationMonitor *locationMonitor;
}

- (void)chatInvitationrecievedNotification:(NSNotification *)notif
{
    MCChatChat *chat = notif.userInfo[kChatField];
    MCChatUser *initiator = notif.userInfo[kUserField];
    if (!self.window.isMiniaturized/*&&self.window.isKeyWindow*/) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSInformationalAlertStyle;
        alert.messageText = [NSString stringWithFormat:@"%@ wants to start chat with you", initiator.name];
        alert.informativeText = [NSString stringWithFormat:@"Theme of the discussion is\"%@\". Do you accept?", chat.theme];
        [alert addButtonWithTitle:@"Accept"];
        [alert addButtonWithTitle:@"Decline"];
        
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"handler");
        
        }];
    } else {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = chat.theme;
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    }
}

- (void)connectMenuClickedNotification:(NSNotification*)notif
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

- (void)startChatMenuClickedNotification:(NSNotification *)notif
{
    if (!(nameSheetWindow||themeSheetWindow)) {
        static NSString *storyBoardName = @"Main";
        static NSString *viewControllerIdentifier = @"EnterThemeController";
        NSStoryboard *mainStoryBoard = [NSStoryboard storyboardWithName:storyBoardName
                                                                 bundle:nil];
        NSViewController *enterThemeViewController = [mainStoryBoard instantiateControllerWithIdentifier:viewControllerIdentifier];
        ((EnterChatThemeController *) enterThemeViewController).users = notif.userInfo[kChatUsersArray];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatInvitationrecievedNotification:) name:kChatInvitationReceivedNotification object:[MCChatClient sharedInstance]];
}

- (BOOL)windowShouldClose:(id)sender
{
    [self.window miniaturize:self];
    return NO;
}

- (void)locationDidChangedTo:(NSString *)locationString
{
    [[MCChatClient sharedInstance] updateMyLocation:locationString];
}

@end
