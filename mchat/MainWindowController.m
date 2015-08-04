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
#import "AcceptChatViewController.h"


@interface MainWindowController ()
- (void)connectMenuClickedNotification:(NSNotification *)notif;
- (void)connectionAttemptEndedNotification:(NSNotification *)notif;
- (void)startChatMenuClickedNotification:(NSNotification *)notif;
- (void)chatInvitationrecievedNotification:(NSNotification *)notif;
- (void)disconnectOccurredNotification:(NSNotification *)notif;
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
        static NSString *storyBoardName = @"Main";
        static NSString *viewControllerIdentifier = @"AcceptChatController";
        NSStoryboard *mainStoryBoard = [NSStoryboard storyboardWithName:storyBoardName
                                                                 bundle:nil];
        AcceptChatViewController *acceptChatViewController = [mainStoryBoard instantiateControllerWithIdentifier:viewControllerIdentifier];
        acceptChatViewController.chat = chat;
        acceptChatViewController.chatInitiator = initiator;
        NSWindow *acceptChatSheetWindow = [NSWindow windowWithContentViewController:acceptChatViewController];
        [self.window beginSheet:acceptChatSheetWindow completionHandler:^(NSModalResponse returnCode) {
            [acceptChatSheetWindow orderOut:self];
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
        [self.window beginSheet:nameSheetWindow completionHandler:^(NSModalResponse returnCode) {
            [nameSheetWindow orderOut:self];
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
        [self.window beginSheet:themeSheetWindow completionHandler:^(NSModalResponse returnCode) {
            [nameSheetWindow orderOut:self];
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
    } else if (notif.userInfo[kExceptionField]&&notif.userInfo[kReasonField]) {
        NSAlert *retryAlert = [[NSAlert alloc] init];
        retryAlert.alertStyle = NSCriticalAlertStyle;
        retryAlert.messageText = @"Unable to establish connection";
        retryAlert.informativeText = @"Looks like there are some communicaton problems";
        [retryAlert addButtonWithTitle:@"Retry"];
        [retryAlert addButtonWithTitle:@"Cancel"];
        [retryAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            switch (returnCode) {
                case NSAlertFirstButtonReturn:
                    [[MCChatClient sharedInstance] connect];
                    break;
                case NSAlertSecondButtonReturn:
                    
                    break;
                default:
                    break;
            }
        }];
    }
}

-(void)disconnectOccurredNotification:(NSNotification *)notif
{
    if (notif.userInfo[kExceptionField]&&notif.userInfo[kReasonField]) {
        NSAlert *reconnectAlert = [[NSAlert alloc] init];
        reconnectAlert.alertStyle = NSCriticalAlertStyle;
        reconnectAlert.messageText = @"The connection was lost";
        reconnectAlert.informativeText = @"Do you want to try to reconnect?";
        [reconnectAlert addButtonWithTitle:@"Reconnect"];
        [reconnectAlert addButtonWithTitle:@"Cancel"];
        [reconnectAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            switch (returnCode) {
                case NSAlertFirstButtonReturn:
                    [[MCChatClient sharedInstance] connect];
                    break;
                case NSAlertSecondButtonReturn:
                    
                    break;
                default:
                    break;
            }
        }];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectOccurredNotification:) name:kDisconnectOccurredNotification object:[MCChatClient sharedInstance]];
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
