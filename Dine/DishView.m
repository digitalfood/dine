//
//  DishView.m
//  Dine
//
//  Created by Joanna Chan on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "DishView.h"

@interface DishView ()

@property (strong, nonatomic) IBOutlet UIImageView *dishImage;
@property (assign, nonatomic) NSInteger dishRating;

@end


@implementation DishView

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]){
        [self setup];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        
        self.dishImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 143, 200)];
        
        [self addSubview:self.dishImage];
        
        self.dishName = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 143, 60)];
        self.dishName.text = @"A Dish";
        
        [self addSubview:self.dishName];
        
        [self setup];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setup {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
//    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - interaction methods
- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    // TODO: pass dish data model to finish data binding in DishDetailViewController
    [self.delegate tapOnDish];
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    // TODO: pass dish data model to finish data binding in DishDetailViewController
//    [self.delegate panOnDish:panGestureRecognizer];
}

@end
