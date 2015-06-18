//
//  MCChatUser.m
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatUser.h"

@implementation MCChatUser
{
    NSUUID *userId;
    __weak MCChatClient *userClient;
}

- (instancetype)initWithUUID:(NSUUID *)uuid
                    userName:(NSString *)name
                   forClient:(MCChatClient *)client
{
    self = [super init];
    if (self) {
        _location = @"Unknown";
        _name = name;
        userId = uuid;
        userClient = client;
    }
    return self;
}

@end
