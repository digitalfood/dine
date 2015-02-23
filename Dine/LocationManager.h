//
//  LocationManager.h
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocation* location;

+ (CLLocationManager *)sharedInstance;

@end
