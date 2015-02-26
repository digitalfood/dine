//
//  ListViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "ListViewController.h"
#import "DishView.h"
#import "Dish.h"

float const DISHVIEW_ASPECTRATIO = 0.5625;

@interface ListViewController () <UIScrollViewDelegate, DishViewDelegate>

@property (nonatomic, assign) CGFloat dishWidth;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.expaned = NO;
    self.reverseSliding = NO;
    [self configureScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DishViewDelegate methods
- (void)tapOnDish:(int)page {
    [self.delegate tapOnDish:page];
}

#pragma mark - Scroll View Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floor((self.scrollView.contentOffset.x - self.dishWidth / 2 ) / self.dishWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - private methods

- (void)configureScrollView
{
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.directionalLockEnabled = YES;
    
    self.scrollView.delegate = self;
}

- (void)setFrame:(CGRect)frame preLayout:(BOOL)preLayout {
    self.dishWidth = frame.size.height * DISHVIEW_ASPECTRATIO;
    self.view.frame = frame;
    
    if (preLayout) {
        [self.view layoutIfNeeded];
    }
    [self resizeSubframes];
}

- (void)setDishes:(NSMutableArray *)dishes {
    _dishes = dishes;
    [self updateUI];
}

- (void)resizeSubframes {
    int i = 0;
    for(DishView *subview in [self.scrollView subviews]) {
        CGFloat xOrigin = i * (self.dishWidth + 1);
        CGRect dishFrame = CGRectMake(xOrigin, 0, self.dishWidth, self.view.frame.size.height);
        subview.frame = dishFrame;
        if (subview.class == [DishView class]) {
            
            subview.contentView.frame = CGRectMake(0, 0, self.dishWidth, dishFrame.size.height);
            [subview updateUI];
            [subview layoutIfNeeded];
        }
        
        i++;
    }
    self.scrollView.contentSize = CGSizeMake(self.dishWidth * self.dishes.count, self.view.frame.size.height);
}

- (void)updateUI {
    for(UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    CGFloat offset = [[UIScreen mainScreen] bounds].size.width;
    offset = self.reverseSliding ? -offset : offset;
    for (int i = 0; i < self.dishes.count; i++) {
        CGFloat xOrigin = i * (self.dishWidth + 1) + offset;
        CGRect dishFrame = CGRectMake(xOrigin, 0, self.dishWidth, self.view.frame.size.height);
        DishView *dishView = [[DishView alloc] initWithFrame:dishFrame];
        [dishView setDish:self.dishes[i]];
        dishView.page = i;
        dishView.delegate = self;
        [self.scrollView addSubview:dishView];
    }
    self.scrollView.contentSize = CGSizeMake(self.dishWidth * self.dishes.count, self.view.frame.size.height);
    [self slideIn];
}

- (void)slideIn {
    self.scrollView.contentOffset = CGPointMake(0, 0);
    int i = 0;
    for(DishView *subview in [self.scrollView subviews]) {
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:0 animations:^{
            CGFloat xOrigin = i * (self.dishWidth + 1);
            CGRect dishFrame = CGRectMake(xOrigin, 0, self.dishWidth, self.view.frame.size.height);
            subview.frame = dishFrame;
            if (subview.class == [DishView class]) {
                subview.contentView.frame = CGRectMake(0, 0, self.dishWidth, self.view.frame.size.height);
                [subview layoutIfNeeded];
            }
        } completion:nil];
        i++;
    }
}

- (void)panOnDish:(int)page withRecognier:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.delegate panOnDish:page withRecognier:panGestureRecognizer];
}

@end
