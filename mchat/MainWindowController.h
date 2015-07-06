//
//  MainWindowController.h
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LocationMonitor.h"

#define kConnectMenuClickedNotification @"kConnectMenuClickedNotification"
#define kStartChatClickedNotification @"kStartChatClickedNotification"
#define kChatUsersArray @"kChatUsersArray"

@interface MainWindowController : NSWindowController<NSWindowDelegate, LocationManagerDelegate>

@end
