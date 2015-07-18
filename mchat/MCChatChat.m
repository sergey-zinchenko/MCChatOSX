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

@synthesize theme = _theme, companions = _companions, chatId = _chatId, initiatedBy = _initiatedBy, client = _client;

- (instancetype)initWithCompanions:(NSArray *)companions
                         chatTheme:(NSString *)theme
                            chatId:(NSUUID *)uid
                         andClient:(MCChatClient *)client
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        _theme = [theme copy];
        _companions = [companions copy];
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

- (void)start
{
    LOG_SELECTOR()
}

- (void)accept
{
    LOG_SELECTOR()
}

- (void)decline
{
    LOG_SELECTOR()
}

- (void)leave
{
    LOG_SELECTOR()
}

@end
