//
//  SelfieImageView.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/2/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfieImageView : UIImageView

@property (strong,nonatomic) UIImageView *iconImageView;
@property (strong,nonatomic) UILabel *descriptionLabel;

- (void)choseImage;
- (void)repositionIcon;
@end
