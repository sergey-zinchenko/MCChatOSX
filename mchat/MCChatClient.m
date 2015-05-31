//
//  MCChatClient.m
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatClient.h"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

@interface MCChatClient ()

@end

@implementation MCChatClient
{
    MCChatCore *core;
    NSMutableDictionary *users;
}

- (instancetype)initWithName:(NSString *)name
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        _name = name;
        users = [[NSMutableDictionary alloc] init];
        core = [[MCChatCore alloc] init];
        core.delegate = self;
    }
    return self;
}

- (void)connect
{
    LOG_SELECTOR()
    if (self.name) {
        [core connect];
    } else
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"Name was not specifyed" userInfo:nil] raise];
}

- (void)disconnect
{
    LOG_SELECTOR()
    [core disconnect];
}

- (void)connectedToServerVersion:(NSUInteger)version
                         forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    [users removeAllObjects];
    [c sendBroadcastMessage:@{@"my_name": self.name}];
}

- (void)exception:(NSString *)exception
       withReason:(NSString *)reason
          forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"Exception > %@ : %@", exception, reason);
}

- (void)userConnected:(NSUUID *)user
              forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
}

- (void)userDisconnected:(NSUUID *)user
                 forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)user
                forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
}

@end
