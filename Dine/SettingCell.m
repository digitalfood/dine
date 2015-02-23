//
//  SettingCell.m
//  Dine
//
//  Created by Matt Ho on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SettingCell.h"

@interface SettingCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SettingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = _name;
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    self.iconImageView.image = _iconImage;
}

- (void)setIconImageUrl:(NSString *)iconImageUrl {
    _iconImageUrl = iconImageUrl;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_iconImageUrl]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil && data != nil) {
            [self setIconImage:[UIImage imageWithData:data]];
        }
    }];
}

@end
