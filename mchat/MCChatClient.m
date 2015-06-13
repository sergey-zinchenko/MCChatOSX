//
//  MCChatClient.m
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatClient.h"
#import "MCChatUser.h"

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
    [c sendBroadcastMessage:@{@"layer" : @"handshake", @"hello": self.name}];
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
    [users removeObjectForKey:user];
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)userid
                forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"%@", message);
    if ([[message allKeys] indexOfObject:@"layer"] != NSNotFound && [message[@"layer"] isKindOfClass:[NSString class]]) {
        NSString *layer = message[@"layer"];
        if ([layer isEqualToString:@"handshake"]) {
            if ([[message allKeys] indexOfObject:@"hello"] != NSNotFound && [message[@"hello"] isKindOfClass:[NSString class]]) {
                NSString *name = message[@"hello"];
                [c sendMessage:@{@"hi" : self.name}
                        toUser:userid];
            }
        }
        
//        
//        [c sendMessage:@{@"my_name" : self.name} toUser:userid];
//        MCChatUser *user = [[MCChatUser alloc] initWithUUID:userid
//                                                   userName:message[@"my_name"]
//                                                  forClient:self];
//        [users setObject:user forKey:userid];
    }
}

@end
