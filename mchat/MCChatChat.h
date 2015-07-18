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


typedef NS_ENUM(NSInteger, MCChatChatInitiator) {
    MCChatChatInitiatedByMe,
    MCChatChatInitiatedByCompanion
};

@protocol MCChatChatDelegate <NSObject>

@end

@interface MCChatChat : NSObject
- (instancetype)initWithCompanions:(NSArray *)companions
                    chatTheme:(NSString *)theme
                       chatId:(NSUUID *)uid
                    andClient:(MCChatClient *)client;

- (void)start;
- (void)accept;
- (void)decline;
- (void)leave;

@property (nonatomic, readonly) MCChatChatInitiator initiatedBy;
@property (nonatomic, readonly) NSUUID *chatId;
@property (nonatomic, readonly) NSString *theme;
@property (nonatomic, readonly) NSArray *companions;
@property (nonatomic, readonly, weak) MCChatClient *client;
@property (nonatomic, weak) id<MCChatChatDelegate> delegate;
@end
