//
//  SectionViewController.h
//  Dine
//
//  Created by Pythis Ting on 2/18/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Restaurant.h"

@protocol SectionViewControllerDelegate <NSObject>

- (void)swipeToRestaurant:(Restaurant *)restaurant rtl:(BOOL)rtl;
- (void)tapOnRestaurant:(Restaurant *)restaurant withGesture:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@interface SectionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) id<SectionViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *restaurants;

- (void)setFrame:(CGRect)frame;
- (void)reloadDataForResult: (NSMutableArray *) restaurants atRestaurant:(NSInteger) index;
- (void) hideRestaurantName: (BOOL) hide;

@end
