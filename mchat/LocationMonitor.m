//
//  LocationMonitor.m
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "LocationMonitor.h"

#define kNotAuthorized @"Not authorized to monitor location"
#define kNotAvailable @""

@interface LocationMonitor ()

@end

@implementation LocationMonitor
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    BOOL firstUpdate;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 1000;
        geocoder = [[CLGeocoder alloc] init];
        firstUpdate = YES;
    }
    return self;
}

- (void)start
{
    if (![CLLocationManager locationServicesEnabled])
        [[NSException exceptionWithName:kLocationManagerException reason:kNotAvailable userInfo:nil] raise];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: case kCLAuthorizationStatusAuthorized:
            {
                [locationManager startUpdatingLocation];
            }
            break;
        default:
            [[NSException exceptionWithName:kLocationManagerException reason:kNotAuthorized userInfo:nil] raise];
            break;
    }
}

- (void)stop
{
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

@end
