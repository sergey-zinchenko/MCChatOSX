//
//  ChatTableCellView.h
//  MChat
//
//  Created by Сергей Зинченко on 31.07.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCChatChat.h"

@interface ChatTableCellView : NSTableCellView

@property (nonatomic, strong, setter=setChat:) MCChatChat *chat;

@end
