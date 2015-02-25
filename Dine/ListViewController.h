//
//  ListViewController.h
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float const DISHVIEW_ASPECTRATIO;

@protocol ListViewControllerDelegate <NSObject>

- (void)tapOnDish:(int)page;
- (void)panOnDish:(int)page withRecognier:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@interface ListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) id<ListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *dishes;
@property (nonatomic, assign) BOOL expaned;
@property (nonatomic, assign) BOOL reverseSliding;
- (void)setFrame:(CGRect)frame;

@end
