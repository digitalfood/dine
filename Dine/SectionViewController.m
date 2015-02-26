//
//  SectionViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/18/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SectionViewController.h"
#import "RestaurantView.h"
#import "YelpClient.h"
#import "Parse/Parse.h"
#import "LocationManager.h"

float const METERS_PER_MILE = 1609.344;

@interface SectionViewController () <UIScrollViewDelegate, LocationManagerDelegate, RestaurantViewDelegate>
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, assign) CGFloat sectionWidth;
@property (nonatomic, assign) CGFloat sectionHeight;

@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) LocationManager *locationManager;

@end

@implementation SectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.client = [YelpClient sharedInstance];
    self.locationManager = [LocationManager sharedInstance];
    self.locationManager.delegate = self;

    CGSize size = [[UIScreen mainScreen] bounds].size;
    self.sectionWidth = size.width;
    self.sectionHeight = self.view.frame.size.height;
    
    if (self.scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [self.view addSubview:self.scrollView];
    }
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.frame.size.height);

    self.scrollView.delegate = self;
    
    if (self.pageControl == nil) {
        self.pageControl = [[UIPageControl alloc] init];
    }
    self.pageControl.hidden = YES;
}

- (void)setFrame:(CGRect)frame {
    self.scrollView.frame = frame;
    self.sectionWidth = frame.size.width;
    self.sectionHeight = frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.sectionHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floor((self.scrollView.contentOffset.x - self.sectionWidth / 2 ) / self.sectionWidth) + 1;
    
    if (self.pageControl.currentPage != page) {
        [self.delegate swipeToRestaurant:self.restaurants[page] rtl:(self.pageControl.currentPage < page)];
    }
    self.pageControl.currentPage = page;
}

#pragma mark - Restaurant View Delegate methods

- (void)tapOnRestaurant:(Restaurant *)restaurant withGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapOnRestaurant:restaurant withGesture:tapGestureRecognizer];
}

#pragma mark - Location Manager Delegate methods

- (void)didUpdateLocation:(CLLocation *)location {
    if (self.location == nil) {
        self.location = location;
        [self reloadData];
    } else {
        self.location = location;
    }
}

#pragma mark - private methods

- (void)reloadData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.location != nil) {
        NSString *currentLocation = [NSString stringWithFormat:@"%+.6f,%+.6f",self.location.coordinate.latitude, self.location.coordinate.longitude];
        [params setObject:currentLocation forKey:@"ll"];
    
        [self.client searchWithTerm:@"Restaurants" params:params success:^(AFHTTPRequestOperation *operation, id response) {
            NSArray *restaurantsDictionary = response[@"businesses"];
            NSArray *restaurants = [Restaurant restaurantsWithDictionaries:restaurantsDictionary];
            self.restaurants = [NSMutableArray arrayWithArray:restaurants];
            [self updateUI: 0];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [error description]);
            [self reloadData];
        }];
    }
}

- (void)updateUI: (NSInteger) currentPage {
    // remove existing restua from
    for(UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    NSInteger numberOfViews = self.restaurants.count;
    
    self.pageControl.numberOfPages = numberOfViews;
    self.pageControl.currentPage = currentPage;
    
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.sectionWidth;
        RestaurantView *restaurantView = [[RestaurantView alloc] init];
        restaurantView.delegate = self;
        restaurantView.frame = CGRectMake(xOrigin, 0, self.sectionWidth, self.sectionHeight);
        restaurantView.restaurant = self.restaurants[i];
        [self.scrollView addSubview:restaurantView];
    }
    self.scrollView.contentSize = CGSizeMake(self.sectionWidth * numberOfViews, self.sectionHeight);
    [self.scrollView scrollRectToVisible:CGRectMake(self.sectionWidth * currentPage, 0, self.sectionWidth, self.sectionHeight) animated:NO];
    [self.delegate swipeToRestaurant:self.restaurants[self.pageControl.currentPage] rtl:YES];
}

- (void)reloadDataForResult: (NSMutableArray *) restaurants atRestaurant:(NSInteger) index {
    self.restaurants = restaurants;
    [self updateUI: index];
    
}

- (void) hideRestaurantName: (BOOL) hide {
    if(hide){
        for(RestaurantView *subview in [self.scrollView subviews]) {
            [subview hideName];
        }
    }else{
        for(RestaurantView *subview in [self.scrollView subviews]) {
            [subview showName];
        }
    }
}

@end
