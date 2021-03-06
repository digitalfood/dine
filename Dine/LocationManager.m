//
//  LocationManager.m
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *clLocationManager;

@end

@implementation LocationManager

+ (LocationManager *)sharedInstance {
    
    static LocationManager *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(instance == nil){            
            if (![CLLocationManager locationServicesEnabled]){
                NSLog(@"location services are disabled");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
                NSLog(@"location services are blocked by the user");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
                NSLog(@"location services are enabled");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
                NSLog(@"about to show a dialog requesting permission");
            }
            
            instance = [[LocationManager alloc] init];
            instance.clLocationManager = [[CLLocationManager alloc] init];
            instance.clLocationManager.delegate = instance;
            instance.clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            instance.clLocationManager.distanceFilter = 100.0f;
            instance.clLocationManager.headingFilter = 5;
            if ([instance.clLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [instance.clLocationManager requestWhenInUseAuthorization];
            }
            if ([CLLocationManager locationServicesEnabled]){
                [instance.clLocationManager startUpdatingLocation];
            }
        }
    });
    
    return instance;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"User has denied location services");
    } else {
        NSLog(@"Location manager did fail with error: %@", error.localizedFailureReason);
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    self.location = [locations lastObject];
    NSDate *date = [NSDate date];
    [date dateByAddingTimeInterval:-60*1];
    if ([self.location.timestamp compare:date] == NSOrderedDescending) {
        [self.clLocationManager stopUpdatingLocation];
    }
    self.clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.delegate didUpdateLocation:self.location];
}

@end
