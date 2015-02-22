//
//  ListViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "ListViewController.h"
#import "DishView.h"
#import "Parse/Parse.h"

float const DISH_RATIO = 0.5625;

@interface ListViewController () <UIScrollViewDelegate, DishViewDelegate>

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


- (void)configureScrollView
{
    _contrainstArray = [[NSMutableArray alloc] init];
    
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    
    self.scrollView.delegate = self;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    // make sure scrollview still works
//    [panGestureRecognizer
//     requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
}

- (void)setFrame:(CGRect)frame {
    self.view.frame = frame;
    self.dishWidth = frame.size.height * DISH_RATIO;
    [self updateUI];
}

- (void)setDishes:(NSMutableArray *)dishes {
    _dishes = dishes;
    
    [self updateUI];
}

- (void)resizeSubframes {
    int i = 0;
    for(UIView *subview in [self.scrollView subviews]) {
        CGFloat xOrigin = i * self.dishWidth;
        CGRect dishFrame = CGRectMake(xOrigin, 0, self.dishWidth, self.view.frame.size.height);
        subview.frame = dishFrame;
        i++;
    }
    self.scrollView.contentSize = CGSizeMake(self.dishWidth * self.dishes.count, self.view.frame.size.height);
}

- (void)updateUI {
    for(UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    int i = 0;
    for (PFObject *dish in self.dishes) {
        CGFloat xOrigin = i * self.dishWidth;
        CGRect dishFrame = CGRectMake(xOrigin, 0, self.dishWidth, self.view.frame.size.height);
        DishView *dishView = [[DishView alloc] initWithFrame:dishFrame];

        dishView.delegate = self;
        dishView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
        
        i++;
        
        dishView.translatesAutoresizingMaskIntoConstraints = NO;
        dishView.dishName.text = dish[@"name"];
        
        [self.scrollView addSubview:dishView];
    }
    self.scrollView.contentSize = CGSizeMake(self.dishWidth * self.dishes.count, self.view.frame.size.height);
}

- (void)tapOnDish {
    [self.delegate tapOnDish];
}

- (void)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.delegate panOnDish:panGestureRecognizer];
}

@end
