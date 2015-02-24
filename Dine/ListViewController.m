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

float const DISH_RATIO = 0.5625;

@interface ListViewController () <UIScrollViewDelegate, DishViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat dishWidth;
@property (nonatomic, strong) NSLayoutConstraint *constraintHeight;
@property (nonatomic, strong) NSMutableArray *contrainstArray;
@property (nonatomic, assign) BOOL pageOpened;
@property (nonatomic, assign) CGRect originalScrollViewFrame;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureScrollView];
//    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPanGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:self.scrollView];
    return fabs(velocity.y) > fabs(velocity.x);
}

- (void)configureScrollView
{
    _contrainstArray = [[NSMutableArray alloc] init];
    
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.directionalLockEnabled = YES;
    
    self.scrollView.delegate = self;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    panGestureRecognizer.delegate = self;
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)setFrame:(CGRect)frame {
    self.view.frame = frame;
    self.dishWidth = frame.size.height * DISH_RATIO;
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
            subview.contentView.frame = CGRectMake(0, 0, self.dishWidth, self.view.frame.size.height);
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
    
    for (int i = 0; i < self.dishes.count; i++) {
        CGRect dishFrame = CGRectMake(0, 0, self.dishWidth, self.view.frame.size.height);
        DishView *dishView = [[DishView alloc] initWithFrame:dishFrame];
        [dishView setDish:self.dishes[i]];

        dishView.delegate = self;
//        dishView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
        
        [self.scrollView addSubview:dishView];
    }
    self.scrollView.contentSize = CGSizeMake(self.dishWidth * self.dishes.count, self.view.frame.size.height);
    
    [self resizeSubframes];
}

- (void)tapOnDish {
    [self.delegate tapOnDish];
}

- (void)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.delegate panOnDish:panGestureRecognizer];
}

@end
