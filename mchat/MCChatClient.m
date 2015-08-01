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
#define kChatLayer @"chat"
#define kStartField @"start"
#define kAcceptedField @"accept"
#define kDeclinedFiled @"decline"
#define kLeftField @"leave"
#define kCompanionsField @"companions"
#define kThemeField @"theme"
#define kLocationField @"location"
#define kHiField @"hi"
#define kHelloField @"hello"

#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define VALID_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatClientDeligate)]&&[obj respondsToSelector:sel])
#define VALID_CHATS_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatClientChatsDeligate)]&&[obj respondsToSelector:sel])
#define VALID_CHATS_CHAT_DELEGATE(obj, sel) (obj&&[obj conformsToProtocol:@protocol(MCChatChatDelegate)]&&[obj respondsToSelector:sel])
#define VALID_MESSAGE_FIELD(msg, field, cls) ([[msg allKeys] indexOfObject:field] != NSNotFound && [msg[field] isKindOfClass:[cls class]])

@interface MCChatClient ()
- (void)addCompanionWithUUID:(NSUUID *)uuid andName:(NSString *)name;
- (void)removeCompanionWithUUID:(NSUUID *)uuid;
- (MCChatCoreStatus)getStatus;
- (NSArray *)getAcceptedChats;
- (NSArray *)getPendingChats;
- (NSArray *)getChats;
- (NSArray *)getCompanions;
- (void)setMyName:(NSString *)name;
@end

@implementation MCChatClient
{
    MCChatCore *core;
    NSMutableDictionary *companions, *chats, *acceptedChats, *pendingChats;
    BOOL connectingNow;
    NSString *myLocation;
}

@synthesize myName = _myName;

- (NSArray *)getChats
{
    LOG_SELECTOR()
    return [chats allValues];
}


- (NSArray *)getPendingChats
{
    LOG_SELECTOR()
    return [pendingChats allValues];
}

- (NSArray *)getAcceptedChats
{
    LOG_SELECTOR()
    return [pendingChats allValues];
}

- (BOOL)isAcceptedChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.client != self)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat does not belong to this client" userInfo:nil] raise];
    return [[acceptedChats allValues] indexOfObject:chat] != NSNotFound;
}

- (BOOL)isPendingChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.client != self)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat does not belong to this client" userInfo:nil] raise];
    return [[pendingChats allValues] indexOfObject:chat] != NSNotFound;
}

- (BOOL)isUnknownChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.client != self)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat does not belong to this client" userInfo:nil] raise];
    return [[chats allValues] indexOfObject:chat] != NSNotFound;
}

- (void)startChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.initiatedBy != MCChatChatInitiatedByMe)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was not initiated by the user" userInfo:nil] raise];
    if ([[acceptedChats allKeys] indexOfObject:chat] != NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was already started or accepted" userInfo:nil] raise];
    NSMutableArray *chatCompanionsUids = [NSMutableArray array], *chatCompanionsUidsStrings = [NSMutableArray array];
    for (MCChatUser *u in chat.companions) {
        [chatCompanionsUids addObject:u.uid];
        [chatCompanionsUidsStrings addObject:[u.uid UUIDString]];
    }
    for (NSUUID *uid in chatCompanionsUids) {
        NSMutableArray *uidsForCurrentCompanion = [chatCompanionsUids mutableCopy];
        [uidsForCurrentCompanion removeObject:uid];
        NSMutableArray *uidsStringsForCurrentCompanion = [chatCompanionsUidsStrings mutableCopy];
        [uidsStringsForCurrentCompanion removeObject:[uid UUIDString]];
        [core sendMessage:@{kLayerFileld:kChatLayer, kStartField:[chat.chatId UUIDString], kThemeField:chat.theme, kCompanionsField:uidsStringsForCurrentCompanion}
                   toUser:uid];
    }
    [chats setObject:chat
              forKey:chat.chatId];
    [acceptedChats setObject:chat
                      forKey:chat.chatId];
    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onChatStarted:forClient:))
        [self.chatsDeligate onChatStarted:chat forClient:self];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatStartedNotification object:self userInfo:@{kChatField: chat}];
}

- (void)acceptChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.initiatedBy != MCChatChatInitiatedByCompanion)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was not initiated by companion" userInfo:nil] raise];
    if ([[pendingChats allKeys] indexOfObject:chat.chatId] == NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat is not pending" userInfo:nil] raise];
    if ([[acceptedChats allKeys] indexOfObject:chat.chatId] != NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was already started or accepted" userInfo:nil] raise];
    NSMutableArray *chatCompanionsUids = [NSMutableArray array];
    for (MCChatUser *u in chat.companions) {
        [chatCompanionsUids addObject:u.uid];
    }
    [core sendMessage:@{kLayerFileld:kChatLayer, kAcceptedField:[chat.chatId UUIDString]} toUsers:chatCompanionsUids];
    [pendingChats removeObjectForKey:chat.chatId];
    [acceptedChats setObject:chat forKey:chat.chatId];
    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onChatAccepted:forClient:))
        [self.chatsDeligate onChatAccepted:chat
                                 forClient:self];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatAcceptedNotification
                                                            object:self
                                                          userInfo:@{kChatField: chat}];
}

- (void)declineChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if (chat.initiatedBy != MCChatChatInitiatedByCompanion)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was not initiated by companion" userInfo:nil] raise];
    if ([[pendingChats allKeys] indexOfObject:chat.chatId] == NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat is not pending" userInfo:nil] raise];
    if ([[acceptedChats allKeys] indexOfObject:chat.chatId] != NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was already started or accepted" userInfo:nil] raise];
    NSMutableArray *chatCompanionsUids = [NSMutableArray array];
    for (MCChatUser *u in chat.companions) {
        [chatCompanionsUids addObject:u.uid];
    }
    [core sendMessage:@{kLayerFileld:kChatLayer, kDeclinedFiled:[chat.chatId UUIDString]} toUsers:chatCompanionsUids];
    [pendingChats removeObjectForKey:chat.chatId];
    [chats removeObjectForKey:chat.chatId];
    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onChatDeclined:forClient:))
        [self.chatsDeligate onChatDeclined:chat
                                 forClient:self];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatDeclinedNotification
                                                            object:self
                                                          userInfo:@{kChatField: chat}];
}

- (void)leaveChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
    if ([[acceptedChats allKeys] indexOfObject:chat.chatId] == NSNotFound)
        [[NSException exceptionWithName:MC_CHAT_CLIENT_EXCEPTION reason:@"This chat was not started or accepted" userInfo:nil] raise];
    NSMutableArray *chatCompanionsUids = [NSMutableArray array];
    for (MCChatUser *u in chat.companions) {
        [chatCompanionsUids addObject:u.uid];
    }
    [core sendMessage:@{kLayerFileld:kChatLayer, kLeftField:[chat.chatId UUIDString]} toUsers:chatCompanionsUids];
    [pendingChats removeObjectForKey:chat.chatId];
    [chats removeObjectForKey:chat.chatId];
    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onChatLeft:forClient:))
        [self.chatsDeligate onChatLeft:chat
                                 forClient:self];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatLeftNotification
                                                            object:self
                                                          userInfo:@{kChatField: chat}];
}

- (void)sendMessage:(NSString *)message
             toChat:(MCChatChat *)chat
{
    LOG_SELECTOR()
}


- (MCChatCoreStatus)getStatus;
{
    LOG_SELECTOR()
    return core.status;
}

- (void)setMyName:(NSString *)myName
{
    LOG_SELECTOR()
    if (myName&&![myName isEqualToString:@""]) {
        _myName = myName;
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
    self = [self init];
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
        acceptedChats = [[NSMutableDictionary alloc] init];
        pendingChats = [[NSMutableDictionary alloc] init];
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
        if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onConnectAttemptStartedForClient:)) {
            [self.chatsDeligate onConnectAttemptStartedForClient:self];
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
    [acceptedChats removeAllObjects];
    [chats removeAllObjects];
    [pendingChats removeAllObjects];
    [c sendBroadcastMessage:@{kLayerFileld : kHandshakeLayer, kHelloField: self.myName}];
    if (connectingNow) {
        if (self.useNotifications)
            [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionAttemptEndedNotifcation object:self userInfo:@{kSuccessFlag : @YES}];
        if VALID_DELEGATE(self.deligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.deligate onConnectAttemptEndedSuccessfully:YES forClient:self];
        }
        if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.chatsDeligate onConnectAttemptEndedSuccessfully:YES forClient:self];
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
        if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onConnectAttemptEndedSuccessfully:forClient:)) {
            [self.chatsDeligate onConnectAttemptEndedSuccessfully:NO forClient:self];
        }
        connectingNow = NO;
    }
    [companions removeAllObjects];
    [acceptedChats removeAllObjects];
    [pendingChats removeAllObjects];
    [chats removeAllObjects];
    if (self.useNotifications)
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectOccurredNotification object:self userInfo:nil];
    if VALID_DELEGATE(self.deligate, @selector(onDisconnectOccurredForClient:))
        [self.deligate onDisconnectOccurredForClient:self];
    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onDisconnectOccurredForClient:))
        [self.chatsDeligate onDisconnectOccurredForClient:self];
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
            
        } else if ([layer isEqualToString:kChatLayer]) {
            if VALID_MESSAGE_FIELD(message, kStartField, NSString) {
                if (VALID_MESSAGE_FIELD(message, kThemeField, NSString) && VALID_MESSAGE_FIELD(message, kCompanionsField, NSArray)) {
                    NSUUID *chatId = [[NSUUID alloc] initWithUUIDString:message[kStartField]];
                    NSMutableArray *companionsIds = [[NSMutableArray alloc] init];
                    [companionsIds addObject:userid];
                    if (!chatId)
                        return;
                    BOOL allUidsValid = YES;
                    for (NSObject *o in message[kCompanionsField]) {
                        if ([o isKindOfClass:[NSString class]]) {
                            NSUUID *companionId = [[NSUUID alloc] initWithUUIDString:(NSString *)o];
                            if (companionId) {
                                [companionsIds addObject:companionId];
                            } else {
                                allUidsValid = NO;
                                break;
                            }
                        } else {
                            allUidsValid = NO;
                            break;
                        }
                    }
                    if (!allUidsValid)
                        return;
                    NSMutableArray *chatCompanions = [NSMutableArray array];
                    for (NSUUID *uid in companionsIds) {
                        MCChatUser *c = [companions objectForKey:uid];
                        if (c)
                            [chatCompanions addObject:c];
                        else
                            return;
                    }
                    MCChatUser *chatInitiator = [companions objectForKey:userid];
                    if (!chatInitiator)
                        return;
                    MCChatChat *chat = [[MCChatChat alloc] initWithCompanions:chatCompanions
                                                           acceptedCompanions:@[chatInitiator]
                                                                    chatTheme:message[kThemeField]
                                                                       chatId:chatId
                                                                    andClient:self];
                    [pendingChats setObject:chat
                                     forKey:chatId];
                    [chats setObject:chat
                              forKey:chatId];
                    if VALID_CHATS_DELEGATE(self.chatsDeligate, @selector(onChatInvitationRecieved:fromUser:forClient:))
                        [self.chatsDeligate onChatInvitationRecieved:chat
                                                            fromUser:chatInitiator
                                                           forClient:self];
                    if (self.useNotifications)
                        [[NSNotificationCenter defaultCenter] postNotificationName:kChatInvitationReceivedNotification object:self userInfo:@{kChatField: chat, kUserField: chatInitiator}];
                }
            } else if VALID_MESSAGE_FIELD(message, kAcceptedField, NSString) {
                NSUUID *chatId = [[NSUUID alloc] initWithUUIDString:message[kAcceptedField]];
                if (!chatId)
                    return;
                MCChatChat *chat = chats[chatId];
                if (!chat)
                    return;
                MCChatUser *companion = companions[userid];
                if (!companion)
                    return;
                if ([chat.companions indexOfObject:companion] == NSNotFound || [chat.acceptedCompanions indexOfObject:companion] != NSNotFound)
                    return;
                [chat.acceptedCompanions addObject:companion];
                if VALID_CHATS_CHAT_DELEGATE(chat.delegate, @selector(onCompanion:acceptedChat:))
                    [chat.delegate onCompanion:companion
                                  acceptedChat:chat];
                if (self.useNotifications)
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChatAcceptedByCompanionNotification object:self userInfo:@{kUserField:companion, kChatField:chat}];

            } else if VALID_MESSAGE_FIELD(message, kDeclinedFiled, NSString) {
                NSUUID *chatId = [[NSUUID alloc] initWithUUIDString:message[kDeclinedFiled]];
                if (!chatId)
                    return;
                MCChatChat *chat = chats[chatId];
                if (!chat)
                    return;
                MCChatUser *companion = companions[userid];
                if (!companion)
                    return;
                if ([chat.companions indexOfObject:companion] == NSNotFound || [chat.acceptedCompanions indexOfObject:companion] != NSNotFound)
                    return;
                [chat.companions removeObject:companion];
                if VALID_CHATS_CHAT_DELEGATE(chat.delegate, @selector(onCompanion:declinedChat:))
                    [chat.delegate onCompanion:companion
                                  declinedChat:chat];
                if (self.useNotifications)
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChatDeclinedByCompanionNotification object:self userInfo:@{kUserField:companion, kChatField:chat}];
            } else if VALID_MESSAGE_FIELD(message, kLeftField, NSString) {
                NSUUID *chatId = [[NSUUID alloc] initWithUUIDString:message[kLeftField]];
                if (!chatId)
                    return;
                MCChatChat *chat = chats[chatId];
                if (!chat)
                    return;
                MCChatUser *companion = companions[userid];
                if (!companion)
                    return;
                if ([chat.companions indexOfObject:companion] == NSNotFound)
                    return;
                [chat.companions removeObject:companion];
                [chat.acceptedCompanions removeObject:companion];
                if VALID_CHATS_CHAT_DELEGATE(chat.delegate, @selector(onCompanion:leftChat:))
                    [chat.delegate onCompanion:companion
                                  leftChat:chat];
                if (self.useNotifications)
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChatLeftByCompanionNotification object:self userInfo:@{kUserField:companion, kChatField:chat}];
            }
        }
        
    }
}

@end
