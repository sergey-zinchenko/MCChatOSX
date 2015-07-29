//
//  AcceptChatViewController.h
//  MChat
//
//  Created by Сергей Зинченко on 29.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCChatChat.h"
#import "MCChatUser.h"

@interface AcceptChatViewController : NSViewController<MCChatChatDelegate>

@property (nonatomic, setter=setChat:) MCChatChat *chat;
@property (nonatomic) MCChatUser *chatInitiator;

@end
