//
//  SearchViewController.h
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@protocol SearchViewControllerDelegate <NSObject>

- (void) searchViewController:(SearchViewController *) searchViewController didSearchRestaurant:(NSMutableArray *)restaurants index:(NSInteger) i;

@end

@interface SearchViewController : UIViewController

@property (nonatomic, weak) id<SearchViewControllerDelegate> delegate;

@end
