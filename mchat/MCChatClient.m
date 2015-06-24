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
#define VALID_MESSAGE_FIELD(msg, field, cls) ([[msg allKeys] indexOfObject:field] != NSNotFound && [msg[field] isKindOfClass:[cls class]])

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
    NSString *myLocation;
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
        self.useNotifications = NO;
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
        connectingNow = YES;
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptStartedNotifcation object:self];
        if VALID_DELEGATE(self.deligate, @selector(onConnectAttemptStartedForClient:)) {
            [self.deligate onConnectAttemptStartedForClient:self];
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

- (void)updateMyLocation:(NSString *)locationString
{
    myLocation = locationString;
    [core sendMessage:@{@"layer":@"user", @"location": locationString}
              toUsers:[companions allKeys]];
}

- (void)connectedToServerVersion:(NSUInteger)version
                         forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    [companions removeAllObjects];
    [c sendBroadcastMessage:@{@"layer" : @"handshake", @"hello": self.myName}];
    if (connectingNow) {
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{kSuccessFlag : @YES}];
        if VALID_DELEGATE(self.deligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.deligate onConnectAttemptEndedSuccessfully:YES forClient:self];
        }
        connectingNow = NO;
    }
}

- (void)disconnectedBecauseOfException:(NSString *)exception
                            withReason:(NSString *)reason
                               forCore:(MCChatCore *)core
{
    
}

- (void)exception:(NSString *)exception
       withReason:(NSString *)reason
          forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"Exception > %@ : %@", exception, reason);
    if (connectingNow) {
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{kSuccessFlag : @NO}];
        if VALID_DELEGATE(self.deligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.deligate onConnectAttemptEndedSuccessfully:NO forClient:self];
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
    if VALID_DELEGATE(self.deligate, @selector(onUserConnected:forClient:)) {
        [self.deligate onUserConnected:companion forClient:self];
    }
}

- (void)removeCompanionWithUUID:(NSUUID *)uuid
{
    LOG_SELECTOR()
    if ([[companions allKeys] indexOfObject:uuid] != NSNotFound) {
        MCChatUser *companion = companions[uuid];
        [companions removeObjectForKey:uuid];
        if VALID_DELEGATE(self.deligate, @selector(onUserDisconnected:forClient:)) {
            [self.deligate onUserDisconnected:companion forClient:self];
        }
    }
}

- (void)messageRecieved:(NSDictionary *)message
               fromUser:(NSUUID *)userid
                forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    NSLog(@"%@ >> %@", [userid UUIDString], message);
    if VALID_MESSAGE_FIELD(message, @"layer", NSString) {
        NSString *layer = message[@"layer"];
        if ([layer isEqualToString:@"handshake"]) {
            if VALID_MESSAGE_FIELD(message, @"hello", NSString) {
                [c sendMessage:@{@"layer" : @"handshake", @"hi" : self.myName}
                        toUser:userid];
                [self addCompanionWithUUID:userid
                                   andName:message[@"hello"]];
                if (myLocation)
                    [c sendMessage:@{@"layer" : @"user", @"location" : myLocation}
                            toUser:userid];
            } else if VALID_MESSAGE_FIELD(message, @"hi", NSString) {
                [self addCompanionWithUUID:userid
                                   andName:message[@"hi"]];
                if (myLocation)
                    [c sendMessage:@{@"layer" : @"user", @"location" : myLocation}
                            toUser:userid];
            }
        } else if ([layer isEqualToString:@"user"]) {
            if VALID_MESSAGE_FIELD(message, @"location", NSString) {
                MCChatUser *companion = companions[userid];
                if (companion) {
                    companion.location = message[@"location"];
                    if VALID_DELEGATE(self.deligate, @selector(onUserInfoChanged:forClient:)) {
                        [self.deligate onUserInfoChanged:companion
                                               forClient:self];
                    }
                }
            }
            
        }
        
    }
}

@end
