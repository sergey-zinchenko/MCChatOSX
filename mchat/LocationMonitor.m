//
//  LocationMonitor.m
//  mchat
//
//  Created by Сергей Зинченко on 16.06.15.
//  Copyright (c) 2015 Sergey Zinchenko. All rights reserved.
//

#import "LocationMonitor.h"

#define kNotAuthorized @"Not authorized to monitor location"
#define kNotAvailable @"Location service not enabled on device"
#define kLocationUnknown @"Unknown"


typedef NS_ENUM(NSInteger, LMState) {
    LMSNotWorking,
    LMSAccuratelyUpdates,
    LMSDirtyUpdates
};

@interface LocationMonitor ()

@end

@implementation LocationMonitor
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    LMState state;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 1000;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        geocoder = [[CLGeocoder alloc] init];
        state = LMSNotWorking;
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
                [self stop];
                [locationManager startUpdatingLocation];
                state = LMSAccuratelyUpdates;
            }
            break;
        default:
            [[NSException exceptionWithName:kLocationManagerException reason:kNotAuthorized userInfo:nil] raise];
            break;
    }
}

- (void)stop
{
    switch (state) {
        case LMSAccuratelyUpdates:
            [locationManager stopUpdatingLocation];
            break;
        case LMSDirtyUpdates:
            [locationManager stopMonitoringSignificantLocationChanges];
            break;
        default:
            break;
    }
    state = LMSNotWorking;
    if (self.delegate&&[self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)])
        [self.delegate locationDidChangedTo:kLocationUnknown];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations&&([locations count] > 0)) {
        CLLocation *mostRecentLocation = [locations lastObject];
        if (state == LMSAccuratelyUpdates) {
            [manager stopUpdatingLocation];
            [manager startMonitoringSignificantLocationChanges];
            state = LMSDirtyUpdates;
        }
        if (!geocoder.isGeocoding) {
            [geocoder reverseGeocodeLocation:mostRecentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (placemarks&&!error&&([placemarks count] > 0)) {
                    CLPlacemark *lp = [placemarks lastObject];
                    NSString *locationString = [NSString stringWithFormat:@"%@, %@, %@, %@ %@", lp.country, lp.administrativeArea, lp.subAdministrativeArea, lp.thoroughfare, lp.subThoroughfare];
                    if (self.delegate&&[self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)])
                        [self.delegate locationDidChangedTo:locationString];
                }
            }];
        }
    }

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error&&error.code == kCLErrorDenied) {
        [self stop];
    }
}

@end
