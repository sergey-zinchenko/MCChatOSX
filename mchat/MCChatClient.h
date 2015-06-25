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

#define kConnectionAttemptStartedNotifcation @"kConnectionAttemptStartedNotifcation"
#define kConnectionAttemptEndedNotifcation @"kConnectionAttemptEndedNotifcation"
#define kSuccessFlag @"kSuccessFlag"
#define kDisconnectOccurredNotification @"kDisconnectOccurredNotification"
#define kUserConnectedNotification @"kUserConnectedNotification"
#define kUserDisconnectedNotification @"kUserDisconnectedNotification"
#define kUserField @"kUserField"

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

@interface MCChatClient : NSObject<MCChatCoreDelegate>
- (instancetype)initWithName:(NSString *)name;
- (void)connect;
- (void)disconnect;
- (void)updateMyLocation:(NSString *)locationString;

+ (MCChatClient *)sharedInstance;

@property (assign, nonatomic) BOOL useNotifications;
@property (weak, nonatomic) id<MCChatClientDeligate> deligate;
@property (getter=getMyName, setter=setMyName:) NSString* myName;
@property (readonly, getter=getCompanions) NSArray* companions;

@end