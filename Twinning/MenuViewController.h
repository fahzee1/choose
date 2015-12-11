//
//  MenuViewController.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+CoreDataProperties.h"

@class MenuViewController;


@protocol MenuDelegate <NSObject>

- (void)menuViewControllerTappedSearch:(MenuViewController *)controller;
-(void)menuViewController:(MenuViewController *)controller tappedCell:(NSString *)cellName;


@end

@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak) id <MenuDelegate> delegate;
@property (strong, nonatomic) User *localUser;
@end
