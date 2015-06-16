//
//  LocationMonitor.m
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "LocationMonitor.h"

@interface LocationMonitor ()

@end

@implementation LocationMonitor
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start
{
    
}

- (void)stop
{
    
}


@end
