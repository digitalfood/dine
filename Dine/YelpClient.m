//
//  YelpClient.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "YelpClient.h"

NSString * const K_YELP_CCONSUMER_KEY = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const K_YELP_CONSUMER_SECRET = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const K_YELP_TOKEN = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const K_YELP_TOKEN_SECRET = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@implementation YelpClient

+ (YelpClient *)sharedInstance {
    
    static YelpClient *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(instance == nil){
            instance = [[YelpClient alloc] initWithConsumerKey:K_YELP_CCONSUMER_KEY consumerSecret:K_YELP_CONSUMER_SECRET accessToken:K_YELP_TOKEN accessSecret:K_YELP_TOKEN_SECRET];
        }
    });
    
    return instance;
    
}


- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken accessSecret:(NSString *)accessSecret {
    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v2/"];
    self = [super initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
    if (self) {
        BDBOAuth1Credential *token = [BDBOAuth1Credential credentialWithToken:accessToken secret:accessSecret expiration:nil];
        [self.requestSerializer saveAccessToken:token];
    }
    return self;
}

- (AFHTTPRequestOperation *)searchWithTerm:(NSString *)term params:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSDictionary *defaults = @{@"term": term};
    NSMutableDictionary *allParameters = [defaults mutableCopy];
    if (params) {
        [allParameters addEntriesFromDictionary:params];
    }
    if (!params[@"ll"]) {
        NSLog(@"location information not found, please enable location service");
    }
    return [self GET:@"search" parameters:allParameters success:success failure:failure];
}

@end
