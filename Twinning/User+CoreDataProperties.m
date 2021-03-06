//
//  User+CoreDataProperties.m
//  Choose
//
//  Created by CJ Ogbuehi on 1/8/16.
//  Copyright © 2016 Gen Y Solutions LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User+CoreDataProperties.h"
#import "constants.h"
#import "APIClient.h"

@implementation User (CoreDataProperties)

@dynamic email;
@dynamic facebook_id;
@dynamic facebook_post;
@dynamic logged_in;
@dynamic name;
@dynamic anonymous;
@dynamic is_staff;

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


- (NSURL *)facebookImageUrl
{
    NSURL *fbUrl;
    if (self.facebook_id){
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.facebook_id];
        fbUrl = [NSURL URLWithString:fbString];
        
    }
    
    return fbUrl;
}

- (NSString *)formattedName
{
    NSString *name = [self.name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    name = [NSString stringWithFormat:@"%@-%@",name,self.facebook_id];
    return name;
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
                 block(APIRequestStatusFail,@{});
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error.localizedDescription);
             
             if (block){
                 block(APIRequestStatusFail,@{});
             }
         }];
    
    
}

+ (void)showCardsWithParams:(NSDictionary *)params
                  GETParams:(NSString *)qString
                      block:(StatusCodeResponseBlock)block
{
    NSString *urlString;
    if (qString){
        urlString = [NSString stringWithFormat:@"%@%@",APICardsString,qString];
    }
    else{
        urlString = APICardsString;
    }
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    APIClient *client = [APIClient sharedClient];
    [client GET:urlString parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
            NSInteger status_code = resp.statusCode;
            if (block){
                block(APIRequestStatusSuccess, responseObject,status_code);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
            NSInteger status_code = resp.statusCode;
            DLog(@"%@",error.localizedDescription);
            if (block){
                block(APIRequestStatusFail,@{},status_code);
            }
        }];
}

+ (void)createCardWithParams:(NSDictionary *)params
                       block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    [client POST:APICardsString parameters:params
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

+ (void)fetchUserCardsWithFBID:(NSString *)fbID
                     GETParams:(NSString *)qString
                         block:(ResponseBlock)block;
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    NSString *urlString;
    if (qString){
        urlString = [NSString stringWithFormat:@"%@/%@/cards?%@",APIUsersString,fbID,qString];
    }
    else{
        urlString = [NSString stringWithFormat:@"%@/%@/cards",APIUsersString,fbID];
    }
    
    [client GET:urlString parameters:@{}
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


+ (void)sendVoteForCard:(NSNumber *)cardID
                   vote:(int)vote
                  block:(ResponseBlock)block
{
    NSParameterAssert(cardID);
    NSParameterAssert(vote);
    
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d",APICardsString,cardID,vote];
    [client POST:urlString parameters:@{}
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

+ (void)getCardWithID:(NSNumber *)cardID
                block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",APICardsString,cardID];
    [client GET:urlString parameters:@{}
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

+ (void)updateCardWithID:(NSNumber *)cardID
              withParams:(NSDictionary *)params
                   block:(nullable ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",APICardsString,cardID];
    [client PUT:urlString parameters:params
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


+ (void)getLatestShareTextWithBlock:(nullable ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APILatestShareString parameters:@{}
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

+ (void)getCardListsForMenu:(nullable ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APICardListsString parameters:@{}
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

+ (void)getMe:(nullable ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client GET:APIMeString parameters:@{}
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
