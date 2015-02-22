//
//  FoodComposeViewController.h
//  Dine
//
//  Created by Matt Ho on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "Restaurant.h"

@protocol FoodComposeViewControllerDelegate <NSObject>

- (void)createFood:(PFObject *)food;

@end


@interface FoodComposeViewController : UIViewController

@property (nonatomic, weak) id<FoodComposeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) Restaurant *restaurant;

@end
