//
//  MCChatClient.h
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCChatCore.h"
#import "MCChatUser.h"
#import "MCChatChat.h"

#define kConnectionAttemptStartedNotifcation @"kConnectionAttemptStartedNotifcation"
#define kConnectionAttemptEndedNotifcation @"kConnectionAttemptEndedNotifcation"
#define kSuccessFlag @"kSuccessFlag"
#define kDisconnectOccurredNotification @"kDisconnectOccurredNotification"
#define kUserConnectedNotification @"kUserConnectedNotification"
#define kUserDisconnectedNotification @"kUserDisconnectedNotification"
#define kChatStartedNotification @"kChatStartedNotification"
#define kChatInvitationReceivedNotification @"kChatInvitationReceivedNotification"
#define kChatAcceptedNotification @"kChatAcceptedNotification"
#define kChatDeclinedNotification @"kChatDeclinedNotification"
#define kChatLeftNotification @"kChatLeftNotification"
#define kUserField @"kUserField"
#define kChatField @"kChatField"

#define MC_CHAT_CLIENT_EXCEPTION @"MCChatClientException"

@class MCChatClient;

@protocol MCChatClientDeligate <NSObject>
@optional
- (void)onConnectAttemptStartedForClient:(MCChatClient *)client;
- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client;
- (void)onDisconnectOccurredForClient:(MCChatClient *)client;
- (void)onUserConnected:(MCChatUser *)user
              forClient:(MCChatClient *)client;
- (void)onUserDisconnected:(MCChatUser *)user
              forClient:(MCChatClient *)client;
- (void)onUserInfoChanged:(MCChatUser *)user
                forClient:(MCChatClient *)client;
@end

@protocol MCChatClientChatsDeligate <NSObject>
@optional
- (void)onConnectAttemptStartedForClient:(MCChatClient *)client;
- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                forClient:(MCChatClient *)client;
- (void)onDisconnectOccurredForClient:(MCChatClient *)client;
- (void)onChatStarted:(MCChatChat *)chat
            forClient:(MCChatClient *)client;
- (void)onChatInvitationRecieved:(MCChatChat *)chat
                        fromUser:(MCChatUser *)user
                       forClient:(MCChatClient *)client;
- (void)onChatAcccpted:(MCChatChat *)chat
             forClient:(MCChatClient *)client;
- (void)onChatDeclined:(MCChatChat *)chat
             forClient:(MCChatClient *)client;
- (void)onChatLeft:(MCChatChat *)chat
             forClient:(MCChatClient *)client;
@end


@interface MCChatClient : NSObject<MCChatCoreDelegate>
- (instancetype)initWithName:(NSString *)name;
- (void)connect;
- (void)disconnect;
- (void)updateMyLocation:(NSString *)locationString;

- (void)startChat:(MCChatChat *)chat;
- (void)acceptChat:(MCChatChat *)chat;
- (void)declineChat:(MCChatChat *)chat;
- (void)leaveChat:(MCChatChat *)chat;
- (void)sendMessage:(NSString *)message
             toChat:(MCChatChat *)chat;

+ (MCChatClient *)sharedInstance;

@property (readonly, getter=getStatus) MCChatCoreStatus status;
@property (assign, nonatomic) BOOL useNotifications;
@property (weak, nonatomic) id<MCChatClientDeligate> deligate;
@property (weak, nonatomic) id<MCChatClientChatsDeligate> chatsDeligate;
@property (getter=getMyName, setter=setMyName:) NSString* myName;
@property (readonly, getter=getCompanions) NSArray* companions;
@property (readonly, getter=getChats) NSArray *chats;
@property (readonly, getter=getPendingChats) NSArray *pendingChats;

@end