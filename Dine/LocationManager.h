//
//  LocationManager.h
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol LocationManagerDelegate <NSObject>

- (void)didUpdateLocation:(CLLocation *)location;

@end

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

+ (LocationManager *)sharedInstance;

@end
