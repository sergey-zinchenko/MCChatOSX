//
//  UserNotificationCoordinator.m
//  MChat
//
//  Created by Сергей Зинченко on 05.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "UserNotificationCoordinator.h"
#import "MCChatClient.h"

#define kChatId @"kChatId"
#define kNotificationType @"kNotificationType"
#define kMessageNotifcation @"kMessageNotifcation"
#define kInvitationNotification @"kInvitationNotification"

@interface UserNotificationCoordinator ()
- (void)simpleMessageReceivedNotification:(NSNotification *)notif;
@end

@implementation UserNotificationCoordinator

@synthesize windowCoordinator = _windowCoordinator, chatClient = _chatClient;

- (void)simpleMessageReceivedNotification:(NSNotification *)notif
{
    MCChatChat *chat = notif.userInfo[kChatField];
    MCChatUser *user = notif.userInfo[kUserField];
    NSString *messageText = notif.userInfo[kMessageTextField];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [NSString stringWithFormat:@"New message from %@ received", user.name];
    notification.informativeText = messageText;
    notification.soundName = @"message-sound.mp3";
    notification.hasReplyButton = YES;
    notification.userInfo = @{kChatId: [chat.chatId UUIDString], kNotificationType: kMessageNotifcation};
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notificationCenter deliverNotification: notification];
}

- (instancetype)initWithChatWindowCoordinator:(ChatWindowCoordinator *)coordinator
                              andChatClient:(MCChatClient *)client
{
    self = [super init];
    if (self) {
        _windowCoordinator = coordinator;
        _chatClient = client;
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simpleMessageReceivedNotification:) name:kSimpleMessageRecievedNotification object:_chatClient];
    }
    return self;
}

+ (UserNotificationCoordinator *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[UserNotificationCoordinator alloc] initWithChatWindowCoordinator:[ChatWindowCoordinator sharedInstance] andChatClient:[MCChatClient sharedInstance]];
    });
    return sharedInstance;
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    NSUUID *chatUUID = [[NSUUID alloc] initWithUUIDString:notification.userInfo[kChatId]];
    MCChatChat *chat = [_chatClient chatForUUID:chatUUID];
    BOOL isWindowVisible = [_windowCoordinator isWindowVisibleForChat:chat];
    if ([notification.userInfo[kNotificationType] isEqualToString:kMessageNotifcation])
        return !isWindowVisible;
    else
        return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification

{
    if ([notification.userInfo[kNotificationType] isEqualToString:kMessageNotifcation]) {
        NSUUID *chatUUID = [[NSUUID alloc] initWithUUIDString:notification.userInfo[kChatId]];
        MCChatChat *chat = [_chatClient chatForUUID:chatUUID];
        if (notification.activationType == NSUserNotificationActivationTypeReplied) {
            [chat sendSimpleMessage:[notification.response string]];
        } else if (notification.activationType == NSUserNotificationActivationTypeContentsClicked) {
            [_windowCoordinator displayWindowForChat:chat];
        }
    }
    [center removeDeliveredNotification:notification];
}

@end
