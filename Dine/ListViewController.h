//
//  ListViewController.h
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float const DISH_RATIO;

@protocol ListViewControllerDelegate <NSObject>

- (void)tapOnDish;
- (void)panOnDish:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@interface ListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) id<ListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *dishes;
- (void)setFrame:(CGRect)frame;

@end
