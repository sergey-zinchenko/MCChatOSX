//
//  ChatWindowCoordinator.h
//  MChat
//
//  Created by Сергей Зинченко on 04.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "MCChatChat.h"

@interface ChatWindowCoordinator : NSObject

+ (ChatWindowCoordinator *)sharedInstance;

- (void)displayWindowForChat:(MCChatChat *)chat;
- (void)hideWindowForChat:(MCChatChat *)chat;
- (void)closeWindowForChat:(MCChatChat *)chat;

@end
