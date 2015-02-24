//
//  checkSplitViewController.h
//  Dine
//
//  Created by Fabián Uribe Herrera on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Restaurant.h"

@interface CheckSplitViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, assign) float amount;
@property (nonatomic, assign) CGRect viewFrame ;

@end
