//
//  CreateVoteController.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+CoreDataProperties.h"

typedef NS_ENUM(NSInteger,CreateCardAs) {
    CreateCardAsStaff = 100,
    CreateCardAsNormal
};

@interface CreateVoteController : UIViewController
@property (strong,nonatomic) User *localUser;
@property (assign) CreateCardAs createCardAs;

@end
