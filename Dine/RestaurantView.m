//
//  RestaurantView.m
//  Dine
//
//  Created by Pythis Ting on 2/18/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "RestaurantView.h"
#import "UIImageView+AFNetworking.h"

@interface RestaurantView() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation RestaurantView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // handle tap gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    self.userInteractionEnabled = YES;
}

- (void)setRestaurant:(Restaurant *)restaurant {
    _restaurant = restaurant;

    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    // set-up image
    self.restaurantImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [[UIScreen mainScreen] bounds].size.height)];
    self.restaurantImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.restaurantImageView setClipsToBounds:YES];
    [self addSubview:self.restaurantImageView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.restaurant.imageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0f];
    
    __weak RestaurantView *rv = self;
    [self.restaurantImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        RestaurantView *stronlyRetainedView = rv;
        [UIView transitionWithView:stronlyRetainedView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ stronlyRetainedView.restaurantImageView.image = image;
        } completion:nil];
    } failure:nil];


    // add overlay to darken the image
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = .3;
    
    [self addSubview:overlay];
    
    // add gradient to the bottom of the image
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.restaurantImageView.frame.size.height/1.5);
    gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.locations = @[@0.00, @0.00, @0.5, @0.98];
    self.restaurantImageView.layer.mask = gradient;
    
    
    // add restaurant name
    UIFont *font = [UIFont systemFontOfSize:25];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect nameLabelRect = [self.restaurant.name boundingRectWithSize:CGSizeMake(self.frame.size.width - 80, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes
                                                        context:nil];
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, nameLabelRect.size.width, nameLabelRect.size.height)];
    self.nameLabel.font = [UIFont systemFontOfSize:25];
    self.nameLabel.text = self.restaurant.name;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.numberOfLines = 2;
    CGRect nameFrame = self.nameLabel.frame;
    nameFrame.origin.y = 35;
    self.nameLabel.frame = nameFrame;

    [self addSubview:self.nameLabel];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - onTap methods
- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapOnRestaurant:self.restaurant withGesture:tapGestureRecognizer];
}

- (void) hideName {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.nameLabel.alpha = 0;
    }];
    
}

- (void) showName {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.nameLabel.alpha = 1;
    }];
}

@end
