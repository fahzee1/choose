//
//  ShareViewController.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/24/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface ShareViewController : UIViewController
@property (strong, nonatomic) UIImage *topImage;
@property (strong, nonatomic) UIImage *shareImage;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *subtitleText;
@property (strong, nonatomic) NSString *imageViewText;
@property (strong, nonatomic) NSString *bottomShareText;
@property (strong,nonatomic) Card *card;
@end
