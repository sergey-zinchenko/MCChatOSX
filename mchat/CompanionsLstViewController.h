//
//  ViewController.h
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCChatClient.h"

#define kConnectionAttemptStartedNotifcation @"kConnectionAttemptStartedNotifcation"
#define kConnectionAttemptEndedNotifcation @"kConnectionAttemptEndedNotifcation"

@interface CompanionsLstViewController : NSViewController<MCChatClientDeligate, NSTableViewDataSource, NSTableViewDelegate>



@end

