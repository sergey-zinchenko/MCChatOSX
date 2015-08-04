//
//  ChatWindowCoordinator.m
//  MChat
//
//  Created by Сергей Зинченко on 04.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatWindowCoordinator.h"
#import "ChatViewController.h"

@interface ChatWindowCoordinator ()
- (NSWindow *)makeNewWindowForChat:(MCChatChat *)chat;
@end

@implementation ChatWindowCoordinator
{
    NSMutableDictionary *windows;
}

- (NSWindow *)makeNewWindowForChat:(MCChatChat *)chat
{
    static NSString *storyBoardName = @"Main";
    static NSString *chatViewControllerIdentifier = @"ChatViewController";
    NSStoryboard *mainStoryBoard = [NSStoryboard storyboardWithName:storyBoardName
                                                             bundle:nil];
    ChatViewController *chatViewController = [mainStoryBoard instantiateControllerWithIdentifier:chatViewControllerIdentifier];
    chatViewController.chat = chat;
    NSWindow *chatWindow = [NSWindow windowWithContentViewController:chatViewController];
    chatWindow.delegate = self;
    return chatWindow;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        windows = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (ChatWindowCoordinator *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[ChatWindowCoordinator alloc] init];
    });
    return sharedInstance;
}

- (void)displayWindowForChat:(MCChatChat *)chat
{
    NSWindow *chatWindow = windows[chat.chatId];
    if (!chatWindow) {
        chatWindow = [self makeNewWindowForChat:chat];
        windows[chat.chatId] = chatWindow;
    }
    [chatWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)hideWindowForChat:(MCChatChat *)chat
{
    
}

- (void)closeWindowForChat:(MCChatChat *)chat
{
    
}

- (BOOL)windowShouldClose:(id)sender
{
    [sender miniaturize:self];
    return NO;
}

@end
