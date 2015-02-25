//
//  DishView.h
//  Dine
//
//  Created by Joanna Chan on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@protocol DishViewDelegate <NSObject>

- (void)tapOnDish:(int)page;
- (void)panOnDish:(int)page withRecognier:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@interface DishView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, weak) id<DishViewDelegate> delegate;
@property (nonatomic, strong) Dish *dish;
@property (nonatomic, assign) int page;

- (void)updateUI;

@end
