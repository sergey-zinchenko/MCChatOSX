//
//  MainWindowController.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MainWindowController.h"


@interface MainWindowController ()
- (void)connectMenuClickedNotification:(NSNotification*)notif;
@end

@implementation MainWindowController
{
    NSWindow *nameSheetWindow;
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


- (void)windowDidLoad {
    [super windowDidLoad];
    //    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    //    closeButton.enabled = YES;
    self.window.delegate = self;
    //self.window.titleVisibility = NSWindowTitleHidden;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectMenuClickedNotification:) name:kConnectMenuClickedNotification object:nil];
    
}

- (BOOL)windowShouldClose:(id)sender
{
    [self.window miniaturize:self];
    return NO;
}

@end
