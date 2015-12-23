//
//  HomeViewController.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HomeViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (strong,nonatomic) NSString *serverLimit;
@property (strong,nonatomic) NSString *serverOffset;
@property (strong,nonatomic) NSString *serverQuery;
@property (strong,nonatomic) NSString *serverUUID;
@end
