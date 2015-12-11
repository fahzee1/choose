//
//  CardViewController.h
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface CardViewController : UIViewController

@property (strong,nonatomic) UIImage *image;
//@property (strong,nonatomic) NSString *titleText;
//@property (strong,nonatomic) NSString *voteText;

@property (strong,nonatomic) Card *card;
@end
