//
//  UserNotificationCoordinator.h
//  MChat
//
//  Created by Сергей Зинченко on 05.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatWindowCoordinator.h"

@interface UserNotificationCoordinator : NSObject<NSUserNotificationCenterDelegate>

- (instancetype)initWithChatWindowCoordinator:(ChatWindowCoordinator *)coordinator
                              andChatClient:(MCChatClient *)client;

@property (nonatomic, strong) ChatWindowCoordinator *windowCoordinator;
@property (nonatomic, strong) MCChatClient *chatClient;

+ (UserNotificationCoordinator *)sharedInstance;

@end