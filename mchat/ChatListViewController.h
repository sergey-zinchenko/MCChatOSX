//
//  ChatListViewController.h
//  MChat
//
//  Created by Сергей Зинченко on 23.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCChatClient.h"

@interface ChatListViewController : NSViewController<MCChatClientChatsDeligate>

@end
