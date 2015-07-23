//
//  MCChatChat.m
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatChat.h"
#import "MCChatClient.h"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));


@implementation MCChatChat

@synthesize theme = _theme, companions = _companions, chatId = _chatId, initiatedBy = _initiatedBy, client = _client, acceptedCompanions = _acceptedCompanions;


- (instancetype) initWithCompanions:(NSArray *)companions
                 acceptedCompanions:(NSArray *)acceptedCompanions
                          chatTheme:(NSString *)theme
                             chatId:(NSUUID *)uid
                          andClient:(MCChatClient *)client
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        _theme = theme?[theme copy]:@"Unspecified";
        _companions = companions?[companions mutableCopy]:[NSMutableArray array];
        _acceptedCompanions = acceptedCompanions ? [acceptedCompanions mutableCopy]:[NSMutableArray array];
        if (uid) {
            _initiatedBy = MCChatChatInitiatedByCompanion;
            _chatId = [uid copy];
        } else {
            _initiatedBy = MCChatChatInitiatedByMe;
            _chatId = [NSUUID UUID];
        }
        if (client)
            _client = client;
        else
            _client = [MCChatClient sharedInstance];
    }
    return self;

}

+ (MCChatChat *) startChatWithCompanions:(NSArray *)companions
                               chatTheme:(NSString *)theme
{
    LOG_SELECTOR()
    MCChatChat *chat = [[MCChatChat alloc] initWithCompanions:companions
                                           acceptedCompanions:@[]
                                                    chatTheme:theme
                                                       chatId:nil
                                                    andClient:nil];
    [chat start];
    return chat;
}

- (void)start
{
    LOG_SELECTOR()
    [self.client startChat:self];
}

- (void)accept
{
    LOG_SELECTOR()
    [self.client acceptChat:self];
}

-(void)decline
{
    LOG_SELECTOR()
    [self.client declineChat:self];
}

- (void)leave
{
    LOG_SELECTOR()
    [self.client leaveChat:self];
}

- (void)sendMessage:(NSString *)message
{
    LOG_SELECTOR()
    [self.client sendMessage:message
                      toChat:self];
}

@end
