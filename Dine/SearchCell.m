//
//  SearchCell.m
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SearchCell.h"
#import "UIImageView+AFNetworking.h"

@interface SearchCell ()

@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *restaurantDistance;
@property (weak, nonatomic) IBOutlet UIImageView *restaurantRating;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddr;

@end

@implementation SearchCell

- (void)awakeFromNib {
    // Initialization code
    self.restaurantImage.layer.cornerRadius = 3;
    self.restaurantImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setRestaurant:(Restaurant *)restaurant {
    _restaurant = restaurant;
    
    [self.restaurantImage setImageWithURL:[NSURL URLWithString:self.restaurant.imageUrl]];
    self.restaurantName.text = self.restaurant.name;
    [self.restaurantRating setImageWithURL:[NSURL URLWithString:self.restaurant.ratingImageUrl]];
    self.restaurantAddr.text = self.restaurant.address;
    self.restaurantDistance.text = [NSString stringWithFormat:@"%.2f mi", self.restaurant.distance];
    
}

@end
