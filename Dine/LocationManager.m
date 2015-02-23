//
//  LocationManager.m
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>
@end

@implementation LocationManager

+ (CLLocationManager *)sharedInstance {
    
    static CLLocationManager *instance = nil;
    
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
            
            instance = [[CLLocationManager alloc] init];
            instance.delegate = self;
            instance.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            instance.distanceFilter = 100.0f;
            instance.headingFilter = 5;
            if ([instance respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [instance requestWhenInUseAuthorization];
            }
            if ([CLLocationManager locationServicesEnabled]){
                [instance startUpdatingLocation];
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
}

@end
