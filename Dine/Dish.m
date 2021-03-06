//
//  Dish.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "Dish.h"

@implementation Dish

- (id)initWithPFObject:(PFObject *)object {
    self = [super init];
    
    if (self) {
        self.name = [object objectForKey:@"name"];
        self.comments = [object objectForKey:@"comments"];
        self.image = [object objectForKey:@"thumbnail"];
        self.ratings = [object objectForKey:@"ratings"];
        self.userName = [object objectForKey:@"fullname"];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        self.name = dictionary[@"name"];
        self.comments = dictionary[@"comments"];
        self.image = dictionary[@"thumbnail"];
        self.ratings = dictionary[@"ratings"];
        self.userName = dictionary[@"fullname"];
    }
    return self;
}

+ (Dish *)dishWithPFObject:(PFObject *)object {
    Dish *dish = [[Dish alloc] initWithPFObject:object];
    return dish;
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
