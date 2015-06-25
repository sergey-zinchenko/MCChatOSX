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
@end

@implementation MainWindowController
{
    NSWindow *nameSheetWindow;
    LocationMonitor *locationMonitor;
}

- (void)connectMenuClickedNotification:(NSNotification*)notif
{
    if (!nameSheetWindow) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectMenuClickedNotification:) name:kConnectMenuClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionAttemptEndedNotification:) name:kConnectionAttemptEndedNotifcation object:[MCChatClient sharedInstance]];
    
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
