//
//  Dish.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "Dish.h"

@implementation Dish

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        self.name = dictionary[@"name"];
        self.image = dictionary[@"thumbnail"];
    }
    return self;
}

+ (NSMutableArray *)dishWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *dishes = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries) {
        Dish *dish = [[Dish alloc] initWithDictionary:dictionary];
        [dishes addObject:dish];
    }
    
    return dishes;
}

@end
