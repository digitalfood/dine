//
//  ListViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "ListViewController.h"
#import "DishView.h"

int const DISH_WIDTH = 143;

@interface ListViewController () <UIScrollViewDelegate, DishViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSLayoutConstraint *constraintHeight;
@property (nonatomic, strong) NSMutableArray *contrainstArray;
@property (nonatomic, assign) BOOL pageOpened;
@property (nonatomic, assign) CGRect originalScrollViewFrame;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureScrollView];
    [self updateUI];
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
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
}

- (void)updateUI {
    for(UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    NSInteger numberOfViews = 10;
    
    for (int i = 0; i < numberOfViews; i++) {

        CGFloat xOrigin = i * DISH_WIDTH;
        CGRect dishFrame = CGRectMake(xOrigin, 0, DISH_WIDTH, self.view.frame.size.height);
        DishView *dishView = [[DishView alloc] initWithFrame:dishFrame];

        dishView.delegate = self;
        dishView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
        
        dishView.translatesAutoresizingMaskIntoConstraints = NO;
        dishView.dishName.text = [NSString stringWithFormat:@"%ld", (long)i];
        
        [self.scrollView addSubview:dishView];
    }
    self.scrollView.contentSize = CGSizeMake(DISH_WIDTH * numberOfViews, self.view.frame.size.height);
}

- (void)tapOnDish {
    [self.delegate tapOnDish];
}

- (void)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.delegate panOnDish:panGestureRecognizer];
}

@end
