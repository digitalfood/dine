//
//  DishView.m
//  Dine
//
//  Created by Joanna Chan on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "DishView.h"

@interface DishView ()

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
        
        self.dishImage = [[UIImageView alloc] initWithFrame:frame];
        
        [self addSubview:self.dishImage];
        
        self.dishName = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 143, 60)];
        self.dishName.text = @"A Dish";
        
        [self addSubview:self.dishName];
        
        [self setup];
    }
    return self;
}


- (void) setup {
    UINib *nib = [UINib nibWithNibName:@"DishView" bundle:[NSBundle mainBundle]];
    [nib instantiateWithOwner:self options:nil];
    
    self.contentView.frame = self.frame;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.contentView];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)setDish:(Dish *)dish {
    _dish = dish;
    
    self.dishName.text = self.dish.name;
    
    [self.dish.image getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.dishImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.dishImage.image = [UIImage imageWithData:imageData];
            self.dishImage.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
    
    self.dishImage.layer.cornerRadius = 3.0;
    [self.dishImage setClipsToBounds:YES];
    
    [self bringSubviewToFront:self.dishName];
}

#pragma mark - interaction methods
- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    // TODO: pass dish data model to finish data binding in DishDetailViewController
    [self.delegate tapOnDish];
}

@end
