//
//  Dish.h
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface Dish : NSObject

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *name;

+ (NSMutableArray *)dishWithDictionaries:(NSArray *)dictionaries;

@end
