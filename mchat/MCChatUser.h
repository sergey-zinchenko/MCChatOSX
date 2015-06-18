//
//  MCChatUser.h
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MCChatClient;

@interface MCChatUser : NSObject

- (instancetype)initWithUUID:(NSUUID *)uuid
                    userName:(NSString *)name
                   forClient:(MCChatClient *)client;
@property (readonly, nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *location;
@end
