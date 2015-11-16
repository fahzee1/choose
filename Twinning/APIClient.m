//
//  APIClient.m
//  Altruus
//
//  Created by CJ Ogbuehi on 5/6/15.
//  Copyright (c) 2015 Altruus LLC. All rights reserved.
//

#import "APIClient.h"
#import "constants.h"
#import <UIKit/UIKit.h>


@implementation APIClient

+ (instancetype)sharedClient
{
    static APIClient *client = nil;
    
    
    // STEP 1
    // get auth key from defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults valueForKey:kLocalUserAuthKey];
    //NSString *authKey = [NSString stringWithFormat:@"Token token=%@",key];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        [client.requestSerializer setValue:key forHTTPHeaderField:@"Authorization"];
        //client.apiKeyFound = YES;
    });
    
    [client.requestSerializer setValue:key forHTTPHeaderField:@"Authorization"];
    return client;
}

- (void)startMonitoringConnection
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                UIAlertView *a = [[UIAlertView alloc]
                                  initWithTitle:@"Oops!"
                                  message:@"There doesn't seem to be an internet connection"
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
                [a show];
            }
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                DLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                DLog(@"3G");
                break;
            default:
                DLog(@"Unknown network");
                break;
        }
    }];
    
}

- (void)stopMonitoringConnection
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)startNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}




@end
