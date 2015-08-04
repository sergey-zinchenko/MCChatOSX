//
//  ChatViewController.h
//  MChat
//
//  Created by Сергей Зинченко on 03.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCChatChat.h"

@interface ChatViewController : NSViewController<MCChatChatDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, setter=setChat:) MCChatChat *chat;

@end