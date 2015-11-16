//
//  APIClient.h
//  Altruus
//
//  Created by CJ Ogbuehi on 5/6/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "AFHTTPSessionManager.h"

// Base
static NSString * const APIBaseUrlString = @"http://192.168.200.187:8000/api/";

// User Endpoints
static NSString * const APILoginString = @"users/login/";
static NSString * const APICardCreateString = @"cards/create/";


@interface APIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)startMonitoringConnection;

- (void)stopMonitoringConnection;

- (void)startNetworkActivity;

- (void)stopNetworkActivity;

@end
