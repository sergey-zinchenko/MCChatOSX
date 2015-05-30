//
//  ChatClient.h
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

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
              forClient:(MCChatCore *)client;
@end

@interface MCChatCore : NSObject
- (instancetype)init;
- (void)disconnect;
- (BOOL)connect;
- (void)sendMessage:(NSDictionary*)meesage;
@property (atomic, weak) id<MCChatCoreDelegate> delegate;
@end