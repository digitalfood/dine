//
//  TipViewController.h
//  Dine
//
//  Created by Pythis Ting on 2/12/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckoutViewController;

@protocol CheckoutViewControllerDelegate <NSObject>

- (void) checkoutViewController:(CheckoutViewController *) checkoutViewController hideText:(BOOL)hide;

@end

@interface CheckoutViewController : UIViewController

- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer;
@property (nonatomic, weak) id<CheckoutViewControllerDelegate> delegate;

@end
