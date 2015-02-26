//
//  DishView.m
//  Dine
//
//  Created by Joanna Chan on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "DishView.h"

@interface DishView () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (strong, nonatomic) IBOutlet UIImageView *dishImage;
@property (nonatomic, strong) NSLayoutConstraint *constraintHeight;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star2Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star3Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star4Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star4Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star5Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *star5Height;

@end


@implementation DishView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        
        [self setup];
    }
    return self;
}


- (void) setup {
    UINib *nib = [UINib nibWithNibName:@"DishView" bundle:[NSBundle mainBundle]];
    [nib instantiateWithOwner:self options:nil];
    
    self.contentView.frame = self.frame;
    [self addSubview:self.contentView];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.star1.contentMode = UIViewContentModeScaleAspectFit;
    self.star2.contentMode = UIViewContentModeScaleAspectFit;
    self.star3.contentMode = UIViewContentModeScaleAspectFit;
    self.star4.contentMode = UIViewContentModeScaleAspectFit;
    self.star5.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)setDish:(Dish *)dish {
    _dish = dish;
    
    self.dishName.text = self.dish.name;
    self.userName.text = [NSString stringWithFormat:@"By %@", self.dish.userName];
    self.dishComments.text = self.dish.comments;
    
    [self.dish.image getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.dishImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.dishImage.image = [UIImage imageWithData:imageData];
            self.dishImage.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
    
    for (int i=1; i<=[self.dish.ratings intValue]; i++) {
        switch (i) {
            case 1:
                [self.star1 setImage:[UIImage imageNamed:@"redStar.png"]];
                break;
            case 2:
                [self.star2 setImage:[UIImage imageNamed:@"redStar.png"]];
                break;
            case 3:
                [self.star3 setImage:[UIImage imageNamed:@"redStar.png"]];
                break;
            case 4:
                [self.star4 setImage:[UIImage imageNamed:@"redStar.png"]];
                break;
            case 5:
                [self.star5 setImage:[UIImage imageNamed:@"redStar.png"]];
                break;
        }
    }
    
    self.layer.cornerRadius = 3.0;
    [self setClipsToBounds:YES];
    
    self.dishImage.layer.cornerRadius = 3.0;
    [self.dishImage setClipsToBounds:YES];
    
    [self bringSubviewToFront:self.dishName];
}

- (void)updateUI{
    
    CGFloat alpha = 0;
    
    if(self.contentView.frame.size.height > 400){
        [self.dishName setFont:[UIFont systemFontOfSize:24]];
        [self.userName setFont:[UIFont systemFontOfSize:20]];
        [self.dishComments setFont:[UIFont systemFontOfSize:20]];
    
        self.star1Width.constant = 24;
        self.star1Height.constant = 24;
        
        self.star2Width.constant = 24;
        self.star2Height.constant = 24;
        
        self.star3Width.constant = 24;
        self.star3Height.constant = 24;
        
        self.star4Width.constant = 24;
        self.star4Height.constant = 24;
        
        self.star5Width.constant = 24;
        self.star5Height.constant = 24;
        alpha = 1;
        
    }else if(self.contentView.frame.size.height < 400){
        [self.dishName setFont:[UIFont systemFontOfSize:15]];
        [self.userName setFont:[UIFont systemFontOfSize:10]];
        [self.dishComments setFont:[UIFont systemFontOfSize:10]];
      
        self.star1Width.constant = 16;
        self.star1Height.constant = 16;
        
        self.star2Width.constant = 16;
        self.star2Height.constant = 16;
        
        self.star3Width.constant = 16;
        self.star3Height.constant = 16;
        
        self.star4Width.constant = 16;
        self.star4Height.constant = 16;
        
        self.star5Width.constant = 16;
        self.star5Height.constant = 16;
        
    }
    
    self.dishName.adjustsFontSizeToFitWidth = YES;
    [self.dishName layoutIfNeeded];
    [self.star1 layoutIfNeeded];
    [self.star2 layoutIfNeeded];
    [self.star3 layoutIfNeeded];
    [self.star4 layoutIfNeeded];
    [self.star5 layoutIfNeeded];
    [self.contentView layoutIfNeeded];
    
    [UIView animateWithDuration:0.8 animations:^{
        self.dishComments.alpha = alpha;
    }];
    
}

#pragma mark - UIPanGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.contentView];
    return fabs(velocity.y) > fabs(velocity.x);
}

#pragma mark - interaction methods
- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.delegate tapOnDish:self.page];
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.delegate panOnDish:self.page withRecognier:panGestureRecognizer];
}

@end
