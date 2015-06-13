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
    NSMutableDictionary *companions;
    NSString *_myName;
}

- (NSString *)getMyName
{
    LOG_SELECTOR()
    return _myName;
}

- (void)setMyName:(NSString *)myName
{
    LOG_SELECTOR()
    if (myName&&![myName isEqualToString:@""]&&![myName isEqualToString:_myName]) {
        [self disconnect];
        _myName = myName;
        [self connect];
    }
}

+ (MCChatClient *)sharedInstance
{
    LOG_SELECTOR()
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
                      sharedInstance = [[MCChatClient alloc] init];
                  });
    return sharedInstance;
}

- (NSArray *)getCompanions
{
    LOG_SELECTOR()
    return [companions allValues];
}

- (instancetype)initWithName:(NSString *)name
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        _myName = name;
    }
    return self;
}

- (instancetype)init
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        companions = [[NSMutableDictionary alloc] init];
        core = [[MCChatCore alloc] init];
        core.delegate = self;
    }
    return self;
}

- (void)connect
{
    LOG_SELECTOR()
    if (self.myName) {
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
    [companions removeAllObjects];
    [c sendBroadcastMessage:@{@"layer" : @"handshake", @"hello": self.myName}];
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
    [companions removeObjectForKey:user];
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
                NSString *companionName = message[@"hello"];
                NSUUID *companionId = userid;
                MCChatUser *companion = [[MCChatUser alloc] initWithUUID:companionId userName:companionName forClient:self];
                [companions setObject:companion forKey:companionId];
                [c sendMessage:@{@"layer" : @"handshake", @"hi" : self.myName}
                        toUser:companionId];
            } else if ([[message allKeys] indexOfObject:@"hi"] != NSNotFound && [message[@"hi"] isKindOfClass:[NSString class]]) {
                NSString *companionName = message[@"hi"];
                NSUUID *companionId = userid;
                MCChatUser *companion = [[MCChatUser alloc] initWithUUID:companionId userName:companionName forClient:self];
                [companions setObject:companion forKey:companionId];
            }
        }
        
    }
}

@end
