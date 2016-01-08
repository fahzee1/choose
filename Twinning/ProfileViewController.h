//
//  ProfileViewController.h
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+CoreDataProperties.h"
#import "Card.h"

typedef NS_ENUM(NSInteger,ProfileScreen){
        ProfileScreenMe,
        ProfileScreenOthers
};
@interface ProfileViewController : UIViewController

@property (strong,nonatomic) User *localUser;
@property (strong,nonatomic) Card *card;
@property (assign) ProfileScreen screenType;

@end
