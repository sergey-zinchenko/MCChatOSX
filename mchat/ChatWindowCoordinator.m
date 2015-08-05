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
- (void)simpleMessageReceivedNotification:(NSNotification *)notif;
@end

@implementation ChatWindowCoordinator
{
    NSMutableArray *windows;
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

- (void)simpleMessageReceivedNotification:(NSNotification *)notif
{
    MCChatChat *chat = notif.userInfo[kChatField];
    MCChatUser *user = notif.userInfo[kUserField];
    NSString *messageText = notif.userInfo[kMessageTextField];
    
    NSWindow *chatWindow = [self getWindowForChat:chat];
    BOOL active = NO;
    for (NSWindow *ww in [[NSApplication sharedApplication] windows]) {
        if (ww.visible&&!ww.miniaturized) {
            active = YES;
            break;
        }
    }
    if (chatWindow) {
        if (active) {
            [SoundEffects playMessageSound];
            [chatWindow orderFront:self];
            [NSApp activateIgnoringOtherApps:YES];
        } else {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = [NSString stringWithFormat:@"New message from %@ received", user.name];
            notification.informativeText = messageText;
            notification.soundName = @"message-sound.mp3";
            notification.hasActionButton = YES;
            notification.actionButtonTitle = @"Open";
            notification.otherButtonTitle = @"Leave";
            //notification.userInfo = notif.userInfo;
            NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
            [notificationCenter deliverNotification: notification];
        }
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        windows = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simpleMessageReceivedNotification:) name:kSimpleMessageRecievedNotification object:[MCChatClient sharedInstance]];
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
