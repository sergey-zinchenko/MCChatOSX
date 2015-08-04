//
//  SimpleMessageTableCellView.h
//  MChat
//
//  Created by Сергей Зинченко on 04.08.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SimpleMessageTableCellView : NSTableCellView

@property (nonatomic, setter=setDate:) NSDate *date;
@property (nonatomic, setter=setMessageText:) NSString *messageText;

@end
