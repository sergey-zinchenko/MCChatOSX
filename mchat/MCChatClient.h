//
//  MCChatClient.h
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCChatCore.h"

#define MC_CHAT_CLIENT_EXCEPTION @"MCChatClientException"

@class MCChatClient;

@protocol MCChatClientDeligate <NSObject>
- (void)onConnectAttemptStartedForClient:(MCChatClient *)client;
- (void)onConnectAttemptEndedSuccessfully:(BOOL)successfully
                                ForClient:(MCChatClient *)client;
@end

@interface MCChatClient : NSObject<MCChatCoreDelegate>
- (instancetype)initWithName:(NSString *)name;
- (void)connect;
- (void)disconnect;

+ (MCChatClient *)sharedInstance;

@property (weak, nonatomic) id<MCChatClientDeligate> deligate;
@property (getter=getMyName, setter=setMyName:) NSString* myName;
@property (readonly, getter=getCompanions) NSArray* companions;

@end