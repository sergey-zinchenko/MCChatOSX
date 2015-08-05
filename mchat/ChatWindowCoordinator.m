//
//  ChatWindowCoordinator.m
//  MChat
//
//  Created by Сергей Зинченко on 04.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ChatWindowCoordinator.h"
#import "ChatViewController.h"
#import "MCChatClient.h"
#import "SoundEffects.h"

#define kWindowKey @"kWindowKey"
#define kChatKey @"kChatKey"

@interface ChatWindowCoordinator ()
- (NSWindow *)makeNewWindowForChat:(MCChatChat *)chat;
- (NSWindow *)getWindowForChat:(MCChatChat *)chat;
- (void)removeWindowForChat:(MCChatChat *)chat;
- (NSWindow *)addWindowForChat:(MCChatChat *)chat;
- (MCChatChat *)getChatForWindow:(NSWindow *)window;
@end

@implementation ChatWindowCoordinator
{
    NSMutableArray *windows;
}

- (BOOL)isWindowVisibleForChat:(MCChatChat *)chat
{
    NSWindow *w = [self getWindowForChat:chat];
    return w.visible&&!w.miniaturized;
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

- (NSWindow *)getWindowForChat:(MCChatChat *)chat
{
    for (NSDictionary *d in windows) {
        if (d[kChatKey] == chat)
            return d[kWindowKey];
    }
    return nil;
}

- (void)removeWindowForChat:(MCChatChat *)chat
{
    for (NSDictionary *d in windows)
        if (d[kChatKey] == chat) {
            [windows removeObject:d];
            return;
        }
}

- (NSWindow *)addWindowForChat:(MCChatChat *)chat
{
    NSWindow *w = [self makeNewWindowForChat:chat];
    [windows addObject:@{kChatKey:chat, kWindowKey:w}];
    return w;
}

- (MCChatChat *)getChatForWindow:(NSWindow *)window
{
    for (NSDictionary *d in windows)
        if (d[kWindowKey] == window) {
            return d[kChatKey];
        }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        windows = [NSMutableArray array];
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
    NSWindow *chatWindow = [self getWindowForChat:chat];
    if (!chatWindow) {
        chatWindow = [self addWindowForChat:chat];
    }
    [chatWindow makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)hideWindowForChat:(MCChatChat *)chat
{
    NSWindow *chatWindow = [self getWindowForChat:chat];
    if (chatWindow) {
        [chatWindow orderOut:self];
    }
}

- (void)closeWindowForChat:(MCChatChat *)chat
{
    NSWindow *chatWindow = [self getWindowForChat:chat];
    if (chatWindow) {
        [chatWindow close];
        [self removeWindowForChat:chat];
    }
}

- (BOOL)windowShouldClose:(id)sender
{
    MCChatChat *chat = [self getChatForWindow:sender];
    if (chat.state == MCChatChatStateUnknown) {
        [self removeWindowForChat:chat];
    }
    return YES;
}

@end
