//
//  ConnectItem.m
//  mchat
//
//  Created by Сергей Зинченко on 13.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "ConnectItem.h"

@implementation ConnectItem

-(void)validate
{
    self.enabled = !self.connectingNow;
}

@end
