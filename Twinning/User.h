//
//  User.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSNumber * facebook_post;
@property (nonatomic, retain) NSNumber * logged_in;

@end
