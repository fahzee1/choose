//
//  User+Utils.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "User+Utils.h"
#import "constants.h"

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

@end
