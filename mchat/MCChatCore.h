//
//  ChatClient.h
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#define MESSAGE_FORMAT_EXCEPTION @"MessageFormatException"
#define ERRONOUS_MESSAGE_PACKAGE @"ErronousMessagePackage"
#define LOWLEVEL_ERROR @"LowLevelError"
#define ERRONOUS_PARAMETERS @"ErronousParameters"

@class MCChatCore;

typedef NS_ENUM(NSInteger, MCChatCoreStatus) {
    MCChatCoreNotConnected,
    MCChatCoreConnecting,
    MCChatCoreConnected
};

@protocol MCChatCoreDelegate <NSObject>
@optional
- (void)connectedToServerVersion:(NSUInteger)version
                       forCore:(MCChatCore *)core;
- (void)disconnectedBecauseOfException:(NSString *)exception
                            withReason:(NSString *)reason
                               forCore:(MCChatCore *)core;
- (void)exception:(NSString *)exception
    withReason:(NSString *)reason
        forCore:(MCChatCore *)core;
- (void)userConnected:(NSUUID *)user
            forCore:(MCChatCore *)core;
- (void)userDisconnected:(NSUUID *)user
               forCore:(MCChatCore *)core;
- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)user
              forCore:(MCChatCore *)core;
@end

@interface MCChatCore : NSObject
- (void)disconnect;
- (BOOL)connect;
- (void)sendMessage:(NSDictionary *)message
             toUser:(NSUUID *)user;
- (void)sendMessage:(NSDictionary *)message
            toUsers:(NSArray *)users;
- (void)sendBroadcastMessage:(NSDictionary *)message;

@property (nonatomic, weak) id<MCChatCoreDelegate> delegate;
@property (readonly, getter=getUsers) NSArray *users;
@property (readonly, getter=getStatus) MCChatCoreStatus status;
@end