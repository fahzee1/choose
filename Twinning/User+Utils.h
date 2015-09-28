//
//  User+Utils.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "User.h"

@interface User (Utils)


+ (User *)createLocalUserInContext:(NSManagedObjectContext *)context;

@end
