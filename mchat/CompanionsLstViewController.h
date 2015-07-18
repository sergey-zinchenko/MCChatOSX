//
//  ViewController.h
//  mchat
//
//  Created by Сергей Зинченко on 03.03.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "MCChatClient.h"

@interface CompanionsLstViewController : NSViewController<MCChatClientDeligate, NSTableViewDataSource, NSTableViewDelegate>



@end

