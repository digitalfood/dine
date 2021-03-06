//
//  RestaurantView.h
//  Dine
//
//  Created by Pythis Ting on 2/18/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@protocol RestaurantViewDelegate <NSObject>

- (void)tapOnRestaurant:(Restaurant *)restaurant withGesture:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@interface RestaurantView : UIView

@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, weak) id<RestaurantViewDelegate> delegate;
- (void) hideName;
- (void) showName;

@end
