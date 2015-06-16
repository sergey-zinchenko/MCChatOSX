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

@protocol MCChatChatDelegate <NSObject>

@end

@interface MCChatChat : NSObject
- (instancetype)initWithUser:(MCChatUser *)user;
- (void)addCompanion:(MCChatUser *)companion;

@property (nonatomic, readonly) NSString *theme;
@property (readonly, nonatomic) NSArray *companions;
@property (nonatomic, weak) id<MCChatChatDelegate> delegate;
@end
