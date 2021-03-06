//
//  User+CoreDataProperties.h
//  Choose
//
//  Created by CJ Ogbuehi on 1/8/16.
//  Copyright © 2016 Gen Y Solutions LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, APIRequestStatus)
{
    APIRequestStatusSuccess,
    APIRequestStatusFail
};


typedef void (^ResponseBlock) (APIRequestStatus status, id data);
typedef void (^StatusCodeResponseBlock) (APIRequestStatus status, id data,NSInteger status_code);

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *facebook_id;
@property (nullable, nonatomic, retain) NSNumber *facebook_post;
@property (nullable, nonatomic, retain) NSNumber *logged_in;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *anonymous;
@property (nullable, nonatomic, retain) NSNumber *is_staff;

- (NSURL *)facebookImageUrl;
- (NSString *)formattedName;

+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context;
+ (User *)getLocalUserInContext:(NSManagedObjectContext *)context;

+ (void)loginWithParams:(NSDictionary *)params
                  block:(nullable ResponseBlock)block;

+ (void)showCardsWithParams:(NSDictionary *)params
                  GETParams:(nullable NSString *)qString
                      block:(nullable StatusCodeResponseBlock)block;

+ (void)createCardWithParams:(NSDictionary *)params
                       block:(nullable ResponseBlock)block;

+ (void)fetchUserCardsWithFBID:(NSString *)fbID
                     GETParams:(nullable NSString *)qString
                         block:(nullable ResponseBlock)block;

+ (void)sendVoteForCard:(NSNumber *)cardID
                   vote:(int)vote
                  block:(nullable ResponseBlock)block;

+ (void)getCardWithID:(NSNumber *)cardID
                block:(nullable ResponseBlock)block;

+ (void)updateCardWithID:(NSNumber *)cardID
              withParams:(NSDictionary *)params
                block:(nullable ResponseBlock)block;

+ (void)getLatestShareTextWithBlock:(nullable ResponseBlock)block;

+ (void)getCardListsForMenu:(nullable ResponseBlock)block;

+ (void)getMe:(nullable ResponseBlock)block;

@end

NS_ASSUME_NONNULL_END
