//
//  User+Utils.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "User.h"

typedef NS_ENUM(NSInteger, APIRequestStatus)
{
    APIRequestStatusSuccess,
    APIRequestStatusFail
};


typedef void (^ResponseBlock) (APIRequestStatus status,id data);

@interface User (Utils)


+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context;
+ (User *)getLocalUserInContext:(NSManagedObjectContext *)context;

+ (void)loginWithParams:(NSDictionary *)params
                  block:(ResponseBlock)block;

+ (void)showCardsWithParams:(NSDictionary *)params
                      GETParams:(NSString *)qString
                     block:(ResponseBlock)block;

+ (void)createCardWithParams:(NSDictionary *)params
                  block:(ResponseBlock)block;

+ (void)fetchMyRecentCards:(NSDictionary *)params
                       block:(ResponseBlock)block;

@end
