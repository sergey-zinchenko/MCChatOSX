//
//  MCChatChat.h
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCChatClient;
@class MCChatUser;
@class MCChatChat;


typedef NS_ENUM(NSInteger, MCChatChatInitiator) {
    MCChatChatInitiatedByMe,
    MCChatChatInitiatedByCompanion
};

typedef NS_ENUM(NSInteger, MCChatChatState) {
    MCChatChatStateAccepted,
    MCChatChatStatePending,
    MCChatChatStateUnknown
};

@protocol MCChatChatDelegate <NSObject>
@optional
- (void)onCompanion:(MCChatUser *)companion
       acceptedChat:(MCChatChat *)chat;
- (void)onCompanion:(MCChatUser *)companion
       declinedChat:(MCChatChat *)chat;
- (void)onCompanion:(MCChatUser *)companion
           leftChat:(MCChatChat *)chat;
- (void)onChatEnded:(MCChatChat *)chat;
- (void)onSimpleMessageRecieved:(NSString *)message
            fromCompanion:(MCChatUser *)companion
                 fromChat:(MCChatChat *)chat;
@end

@interface MCChatChat : NSObject

- (instancetype) initWithCompanions:(NSArray *)companions
                 acceptedCompanions:(NSArray *)acceptedCompanions
                          chatTheme:(NSString *)theme
                             chatId:(NSUUID *)uid
                          andClient:(MCChatClient *)client;

+ (MCChatChat *) startChatWithCompanions:(NSArray *)companions
                               chatTheme:(NSString *)theme;

- (void)start;
- (void)accept;
- (void)decline;
- (void)leave;
- (void)sendMessage:(NSString *)message;

@property (nonatomic, readonly) MCChatChatInitiator initiatedBy;
@property (nonatomic, readonly, getter=getState) MCChatChatState state;
@property (nonatomic, readonly) NSUUID *chatId;
@property (nonatomic, readonly) NSString *theme;
@property (nonatomic, readonly) NSMutableArray *companions;
@property (nonatomic, readonly) NSMutableArray *acceptedCompanions;
@property (nonatomic, readonly, weak) MCChatClient *client;
@property (nonatomic, weak) id<MCChatChatDelegate> delegate;

@end
