//
//  LocationMonitor.h
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>
- (void)locationDidChangedTo:(NSString *)locationString;
@end

@interface LocationMonitor : NSObject<CLLocationManagerDelegate, CLLocationManagerDelegate>
{
    
}

- (void)start;
- (void)stop;

@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

@end
