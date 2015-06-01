//
//  MCChatUser.h
//  mchat
//
//  Created by Сергей Зинченко on 31.05.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCChatClient.h"

@interface MCChatUser : NSObject

- (instancetype)initWithUUID:(NSUUID *)uuid
                    userName:(NSString *)name
                   forClient:(MCChatClient *)client;
@property (readonly, strong) NSString *name;
@end
