//
//  ChatClient.h
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#define MESSAGE_FORMAT_EXCEPTION @"MessageFormatException"
#define ERRONOUS_MESSAGE_PACKAGE @"ErronousMessagePackage"

@class MCChatCore;

@protocol MCChatCoreDelegate <NSObject>
- (void)connectedToServerVersion:(NSUInteger)version
                       forClient:(MCChatCore *)client;
- (void)connectingFailedforClient:(MCChatCore *)client;
- (void)userConnected:(NSString *)user
            forClient:(MCChatCore *)client;
- (void)userDisconnected:(NSString *)user
               forClient:(MCChatCore *)client;
- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSString *)user
              forClient:(MCChatCore *)client;
@end

@interface MCChatCore : NSObject
- (void)disconnect;
- (BOOL)connect;
- (void)sendMessage:(NSDictionary*)meesage;
@property (atomic, weak) id<MCChatCoreDelegate> delegate;
@property (readonly, getter=getUsers) NSArray *users;
@end