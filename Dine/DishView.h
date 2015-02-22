//
//  DishView.h
//  Dine
//
//  Created by Joanna Chan on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DishViewDelegate <NSObject>

- (void)tapOnDish;
//- (void)panOnDish:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@interface DishView : UIView

@property (nonatomic, weak) id<DishViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *dishName;

@end
