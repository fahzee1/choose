//
//  SocialIconButton.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/9/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "SocialIconButton.h"
#import "UIColor+HexValue.h"
#import "constants.h"
#import <FAKIonIcons.h>

@implementation SocialIconButton


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(5, -20, 0, 0)];
}
- (void)makeFacebookButton
{
    [self setTitle:@"" forState:UIControlStateNormal];
    FAKIonIcons *fbIcon = [FAKIonIcons socialFacebookIconWithSize:35];
    [fbIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *icon = [fbIcon imageWithSize:CGSizeMake(35, 35)];
    self.backgroundColor = [UIColor colorWithHexString:kColorFacebook];
    [self layoutIfNeeded];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.center = [self convertPoint:self.center fromView:self.superview];
    [self addSubview:imageView];
    
}

- (void)makeTwitterButton
{
    [self setTitle:@"" forState:UIControlStateNormal];
    FAKIonIcons *twIcon = [FAKIonIcons socialTwitterIconWithSize:35];
    [twIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *icon = [twIcon imageWithSize:CGSizeMake(35, 35)];
    self.backgroundColor = [UIColor colorWithHexString:kColorTwitter];
    [self layoutIfNeeded];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.center = [self convertPoint:self.center fromView:self.superview];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
}

- (void)makeMoreButton
{
    [self setTitle:@"" forState:UIControlStateNormal];
    FAKIonIcons *moreIcon = [FAKIonIcons moreIconWithSize:35];
    [moreIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *icon = [moreIcon imageWithSize:CGSizeMake(35, 35)];
    self.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    [self layoutIfNeeded];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.center = [self convertPoint:self.center fromView:self.superview];
    [self addSubview:imageView];
}

- (void)makeInstagramButton
{
    [self setTitle:@"" forState:UIControlStateNormal];
    FAKIonIcons *igIcon = [FAKIonIcons socialInstagramIconWithSize:35];
    [igIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *icon = [igIcon imageWithSize:CGSizeMake(35, 35)];
    self.backgroundColor = [UIColor colorWithHexString:kColorInstagram];
    [self layoutIfNeeded];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(0, 0, 35, 35);
    imageView.center = [self convertPoint:self.center fromView:self.superview];
    [self addSubview:imageView];
}

- (void)setType:(SocialButton)type
{
    _type = type;
    
    switch (type) {
        case SocialButtonFacebook:
        {
            [self makeFacebookButton];
        }
            break;
        case SocialButtonTwitter:
        {
            [self makeTwitterButton];
        }
            break;
        case SocialButtonInstagram:
        {
            [self makeInstagramButton];
        }
            break;
        case SocialButtonMore:
        {
            [self makeMoreButton];
        }
            break;
        default:
            break;
    }
}
@end
