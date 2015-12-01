//
//  User+Utils.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "User+Utils.h"
#import "constants.h"
#import "APIClient.h"

@implementation User (Utils)


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.logged_in = [NSNumber numberWithBool:NO];
    
    
    
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
    
}

+ (NSString *)name
{
    return @"User";
}


+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context
{
    User *user = [NSEntityDescription insertNewObjectForEntityForName:[User name] inManagedObjectContext:context];
    NSError *e;
    if (![user.managedObjectContext save:&e]){
        DLog(@"Unresolved error %@, %@", e, [e userInfo]);
        abort();
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *objectID = [[user objectID] URIRepresentation];
    [defaults setURL:objectID forKey:kLocalUser];
    
    
    
    
    return user;
    
}

+ (User *)getLocalUserInContext:(NSManagedObjectContext *)context
{
    // hold value in constants
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *objectURL = [defaults URLForKey:kLocalUser];
    NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURL];
    NSError *e;
    NSManagedObject *userObject = [context existingObjectWithID:objectID error:&e];
    if (!userObject){
        DLog(@"error %@",e);
        abort();
    }
    
    return (User *)userObject;
}


+ (void)loginWithParams:(NSDictionary *)params
                  block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APILoginString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             
             id success = responseObject[@"success"];
             //NSString *userToken = responseObject[@"user"][@"authentication_token"];
             if ((BOOL)success && block){
                 block(APIRequestStatusSuccess,responseObject);
             }
             else{
                 block(APIRequestStatusFail,nil);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             
             if (block){
                 block(APIRequestStatusFail,nil);
             }
         }];
    
    
}

+ (void)showCardsWithParams:(NSDictionary *)params
                  GETParams:(NSString *)qString
                      block:(ResponseBlock)block
{
    NSString *urlString;
    if (qString){
        urlString = [NSString stringWithFormat:@"%@%@",APICardsString,qString];
    }
    else{
        urlString = APICardsString;
    }
    
    APIClient *client = [APIClient sharedClient];
    [client GET:urlString parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            if (block){
                block(APIRequestStatusSuccess, responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(APIRequestStatusFail,nil);
            }
        }];
}

+ (void)createCardWithParams:(NSDictionary *)params
                       block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client POST:APICardCreateString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess,responseObject);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"error is %@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,error.localizedDescription);
             }
         }];
}

+ (void)fetchMyRecentCards:(NSDictionary *)params
                     block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client POST:APIUserRecentCards parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             if (block){
                 block(APIRequestStatusSuccess,responseObject);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"error is %@",error.localizedDescription);
             if (block){
                 block(APIRequestStatusFail,error.localizedDescription);
             }
         }];
}

@end
