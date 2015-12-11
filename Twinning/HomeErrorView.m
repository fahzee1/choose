//
//  HomeErrorView.m
//  Choose
//
//  Created by CJ Ogbuehi on 12/8/15.
//  Copyright © 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeErrorView.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import "UIColor+HexValue.h"

@implementation HomeErrorView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithHexString:kColorRed];
    self.layer.cornerRadius = 10;
    
    FAKIonIcons *sadIcon = [FAKIonIcons sadIconWithSize:40];
    [sadIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.imageView.image = [sadIcon imageWithSize:CGSizeMake(40, 40)];
    
    self.label.font = [UIFont fontWithName:kFontGlobalBold size:18];
    self.label.textColor = [UIColor whiteColor];
    self.label.text = NSLocalizedString(@"Looks like we couldn't find any cards for you today. Let's try again", nil);
    
    [self.button setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont fontWithName:kFontGlobal size:14];
    [self.button setTitleColor:[UIColor colorWithHexString:kColorRed] forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor whiteColor];
    self.button.layer.cornerRadius = 10;
}

- (IBAction)tappedAction:(UIButton *)sender {
    if (self.delegate){
        [self.delegate homeErrorViewTappedButton:self];
    }
}

@end
