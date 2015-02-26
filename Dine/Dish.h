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
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) NSNumber *ratings;
@property (nonatomic, strong) NSString *userName;

+ (Dish *)dishWithPFObject:(PFObject *)object;
+ (NSMutableArray *)dishWithDictionaries:(NSArray *)dictionaries;

@end
