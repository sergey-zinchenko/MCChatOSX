//
//  MCChatClient.m
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatClient.h"
#import "MCChatUser.h"
#import "MCChatChat.h"

#define kLayerFileld @"layer"
#define kHandshakeLayer @"handshake"
#define kUserLayer @"user"
#define kLocationField @"location"
#define kHiField @"hi"
#define kHelloField @"hello"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define VALID_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatClientDeligate)]&&[obj respondsToSelector:sel])
#define VALID_MESSAGE_FIELD(msg, field, cls) ([[msg allKeys] indexOfObject:field] != NSNotFound && [msg[field] isKindOfClass:[cls class]])

@interface MCChatClient ()
- (void)addCompanionWithUUID:(NSUUID *)uuid andName:(NSString *)name;
- (void)removeCompanionWithUUID:(NSUUID *)uuid;
- (MCChatCoreStatus)getStatus;
@end

@implementation MCChatClient
{
    MCChatCore *core;
    NSMutableDictionary *companions;
    NSMutableDictionary *chats;
    NSString *_myName;
    BOOL connectingNow;
    NSString *myLocation;
}

- (void)startChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
}

- (void)acceptChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
}

- (void)declineChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
}

- (void)leaveChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
}


- (MCChatCoreStatus)getStatus;
{
    LOG_SELECTOR()
    return core.status;
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
        chats = [[NSMutableDictionary alloc] init];
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
    [core sendMessage:@{kLayerFileld : kUserLayer, kLocationField : locationString}
              toUsers:[companions allKeys]];
}

- (void)connectedToServerVersion:(NSUInteger)version
                         forCore:(MCChatCore *)c
{
    LOG_SELECTOR()
    [companions removeAllObjects];
    [chats removeAllObjects];
    [c sendBroadcastMessage:@{kLayerFileld : kHandshakeLayer, kHelloField: self.myName}];
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
    if (connectingNow) {
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{kSuccessFlag : @NO}];
        if VALID_DELEGATE(self.deligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.deligate onConnectAttemptEndedSuccessfully:NO forClient:self];
        }
        connectingNow = NO;
    }
    [companions removeAllObjects];
    [chats removeAllObjects];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectOccurredNotification object:self userInfo:nil];
    if VALID_DELEGATE(self.deligate, @selector(onDisconnectOccurredForClient:))
        [self.deligate onDisconnectOccurredForClient:self];
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
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserConnectedNotification object:self userInfo:@{kUserField : companion}];
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
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserDisconnectedNotification object:self userInfo:@{kUserField : companion}];
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
    if VALID_MESSAGE_FIELD(message, kLayerFileld, NSString) {
        NSString *layer = message[kLayerFileld];
        if ([layer isEqualToString:kHandshakeLayer]) {
            if VALID_MESSAGE_FIELD(message, kHelloField, NSString) {
                [c sendMessage:@{kLayerFileld : kHandshakeLayer, kHiField : self.myName}
                        toUser:userid];
                [self addCompanionWithUUID:userid
                                   andName:message[kHelloField]];
                if (myLocation)
                    [c sendMessage:@{kLayerFileld : kUserLayer, kLocationField : myLocation}
                            toUser:userid];
            } else if VALID_MESSAGE_FIELD(message, kHiField, NSString) {
                [self addCompanionWithUUID:userid
                                   andName:message[kHiField]];
                if (myLocation)
                    [c sendMessage:@{kLayerFileld : kUserLayer, kLocationField : myLocation}
                            toUser:userid];
            }
        } else if ([layer isEqualToString:kUserLayer]) {
            if VALID_MESSAGE_FIELD(message, kLocationField, NSString) {
                MCChatUser *companion = companions[userid];
                if (companion) {
                    companion.location = message[kLocationField];
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
