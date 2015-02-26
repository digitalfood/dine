//
//  RestaurantDetailViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface RestaurantDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (weak, nonatomic) IBOutlet UILabel *restName;
@property (weak, nonatomic) IBOutlet UIImageView *restRatings;
@property (weak, nonatomic) IBOutlet UILabel *restDistance;
@property (weak, nonatomic) IBOutlet UILabel *restAddr;
@property (weak, nonatomic) IBOutlet UILabel *restCate;
@property (weak, nonatomic) IBOutlet UIView *detailShadow;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restaurantImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.restaurantImageView setClipsToBounds:YES];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panDetailGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDetailPan:)];
    [self.detailView addGestureRecognizer:panDetailGestureRecognizer];
    
    self.restName.text = self.restaurant.name;
    [self.restRatings setImageWithURL:[NSURL URLWithString:self.restaurant.ratingImageUrl]];
    self.restDistance.text = [NSString stringWithFormat:@"%.2f mi", self.restaurant.distance];
    self.restAddr.text = self.restaurant.address;
    self.restCate.text = self.restaurant.categories;

    self.view.userInteractionEnabled = YES;
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.restaurant.imageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    
    __weak RestaurantDetailViewController *this = self;
    [self.restaurantImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        RestaurantDetailViewController *stronglyRetainedView = this;
        [UIView transitionWithView:stronglyRetainedView.restaurantImageView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ stronglyRetainedView.restaurantImageView.image = image;
        } completion:nil];
    } failure:nil];
    
}

#pragma mark - Gesture methods

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDetailPan:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [sender velocityInView:self.view];
        
        if (velocity.y > 0) {
            [UIView animateWithDuration:0.5 animations:^{
                CGFloat screenSize = self.view.frame.size.height - 35;
                
                CGRect frame = self.detailView.frame;
                frame.origin.y = screenSize;
                self.detailView.frame = frame;
                
                CGRect sframe = self.detailShadow.frame;
                sframe.origin.y = screenSize;
                self.detailShadow.frame = sframe;
            }];
        } else if (velocity.y < 0) {
            [UIView animateWithDuration:0.5 animations:^{
               
                CGRect frame = self.detailView.frame;
                frame.origin.y = 467;
                self.detailView.frame = frame;
                
                CGRect sframe = self.detailShadow.frame;
                sframe.origin.y = 467;
                self.detailShadow.frame = sframe;
                
            }];
        }
    }

}

@end
