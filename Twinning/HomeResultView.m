//
//  HomeResultView.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/7/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeResultView.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import "UIColor+HexValue.h"


@implementation HomeResultView
- (void)awakeFromNib
{
    self.seperatorView.backgroundColor = [UIColor whiteColor];
    self.leftImageView.clipsToBounds = YES;
    self.rightImageView.clipsToBounds = YES;
    self.leftImageView.layer.cornerRadius = self.leftImageView.frame.size.height/2;
    self.rightImageView.layer.cornerRadius = self.rightImageView.frame.size.height/2;
    self.leftImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.rightImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.leftImageView.layer.borderWidth = 3.0;
    self.rightImageView.layer.borderWidth = 3.0;
    
    FAKIonIcons *checkIcon = [FAKIonIcons checkmarkIconWithSize:30];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.leftImageView.image = [checkIcon imageWithSize:CGSizeMake(45, 45)];
    self.rightImageView.image = [checkIcon imageWithSize:CGSizeMake(45, 45)];
    
    self.leftLabel.font = [UIFont fontWithName:kFontGlobalBold size:15];
    self.rightLabel.font = [UIFont fontWithName:kFontGlobalBold size:15];

    
    
}

- (void)showLeft
{
    self.hidden = NO;
    self.alpha = 1;
    self.rightImageView.hidden = YES;
    self.rightImageView.alpha = 0;
    self.leftImageView.hidden = NO;
    self.leftImageView.alpha = 1;
    
}
- (void)showRight
{
    self.hidden = NO;
    self.alpha = 1;
    self.rightImageView.hidden = NO;
    self.rightImageView.alpha = 1;
    self.leftImageView.hidden = YES;
    self.leftImageView.alpha = 0;
    
}

- (void)hide
{
    self.hidden = YES;
}

@end
