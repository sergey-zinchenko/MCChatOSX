//
//  MCChatUser.m
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "MCChatUser.h"
#define LOG_SELECTOR()  NSLog(@"%@ > %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

@implementation MCChatUser

@synthesize location = _location, name = _name, uid = _uid, client = _client;

- (instancetype)initWithUUID:(NSUUID *)uuid
                    userName:(NSString *)name
                   forClient:(MCChatClient *)client
{
    LOG_SELECTOR()
    self = [super init];
    if (self) {
        _location = @"Unknown";
        _name = name;
        _uid = uuid;
        _client = client;
    }
    return self;
}

@end
