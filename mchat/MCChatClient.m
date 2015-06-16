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
#define VALID_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatClientDeligate)]&&[obj respondsToSelector:sel])

@interface MCChatClient ()
- (void)addCompanionWithUUID:(NSUUID *)uuid andName:(NSString *)name;
- (void)removeCompanionWithUUID:(NSUUID *)uuid;
@end

@implementation MCChatClient
{
    MCChatCore *core;
    NSMutableDictionary *companions;
    NSString *_myName;
    BOOL connectingNow;
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
        connectingNow = NO;
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
        id<MCChatClientDeligate> d = self.deligate;
        connectingNow = YES;
        if VALID_DELEGATE(d, @selector(onConnectAttemptStartedForClient:)) {
            [d onConnectAttemptStartedForClient:self];
        }
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
    id<MCChatClientDeligate> d = self.deligate;
    if (connectingNow) {
        if VALID_DELEGATE(d, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [d onConnectAttemptEndedSuccessfully:YES forClient:self];
        }
        connectingNow = NO;
    }
}

- (void)exception:(NSString *)exception
       withReason:(NSString *)reason
          forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"Exception > %@ : %@", exception, reason);
    id<MCChatClientDeligate> d = self.deligate;
    if (connectingNow) {
        if VALID_DELEGATE(d, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [d onConnectAttemptEndedSuccessfully:NO forClient:self];
        }
        connectingNow = NO;
    }
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
    [self removeCompanionWithUUID:user];
}

- (void)addCompanionWithUUID:(NSUUID *)uuid
                     andName:(NSString *)name
{
    LOG_SELECTOR()
    MCChatUser *companion = [[MCChatUser alloc] initWithUUID:uuid
                                                    userName:name
                                                   forClient:self];
    [companions setObject:companion forKey:uuid];
    id<MCChatClientDeligate> d = self.deligate;
    if VALID_DELEGATE(d, @selector(onUserConnected:forClient:)) {
        [d onUserConnected:companion forClient:self];
    }
}

- (void)removeCompanionWithUUID:(NSUUID *)uuid
{
    LOG_SELECTOR()
    if ([[companions allKeys] indexOfObject:uuid] != NSNotFound) {
        MCChatUser *companion = companions[uuid];
        [companions removeObjectForKey:uuid];
        id<MCChatClientDeligate> d = self.deligate;
        if VALID_DELEGATE(d, @selector(onUserDisconnected:forClient:)) {
            [d onUserDisconnected:companion forClient:self];
        }
    }
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)userid
                forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"%@ >> %@", [userid UUIDString], message);
    if ([[message allKeys] indexOfObject:@"layer"] != NSNotFound && [message[@"layer"] isKindOfClass:[NSString class]]) {
        NSString *layer = message[@"layer"];
        if ([layer isEqualToString:@"handshake"]) {
            if ([[message allKeys] indexOfObject:@"hello"] != NSNotFound && [message[@"hello"] isKindOfClass:[NSString class]]) {
                [c sendMessage:@{@"layer" : @"handshake", @"hi" : self.myName}
                        toUser:userid];
                [self addCompanionWithUUID:userid
                                   andName:message[@"hello"]];
            } else if ([[message allKeys] indexOfObject:@"hi"] != NSNotFound && [message[@"hi"] isKindOfClass:[NSString class]]) {
                [self addCompanionWithUUID:userid
                                   andName:message[@"hi"]];
            }
        }
        
    }
}

@end
