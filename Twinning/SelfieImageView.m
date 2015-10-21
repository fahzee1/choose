//
//  SelfieImageView.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/2/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "SelfieImageView.h"
#import <FAKIonIcons.h>
#import "constants.h"
#import "UIColor+HexValue.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation SelfieImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = .5;
    
    FAKIonIcons *openIcon = [FAKIonIcons plusCircledIconWithSize:35];
    [openIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorRed]];
    openIcon.drawingBackgroundColor = [UIColor whiteColor];
    UIImage *openImage = [openIcon imageWithSize:CGSizeMake(35, 35)];
    self.iconImageView = [[UIImageView alloc] initWithImage:openImage];
    self.iconImageView.frame = CGRectMake(0, 0, 35, 35);
    self.iconImageView.center = [self convertPoint:self.center fromView:self.superview];
    self.iconImageView.layer.cornerRadius = 17.5;
    CGRect imageViewFrame = self.iconImageView.frame;
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageViewFrame.origin.x, imageViewFrame.origin.y + imageViewFrame.size.height + 5, 50, 15)];
    self.descriptionLabel.text = NSLocalizedString(@"Choose Image", nil);
    self.descriptionLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.descriptionLabel];
    
    
}

- (CGSize)intrinsicContentSize
{
    
    return CGSizeMake(150, 100);
}

- (void)repositionIcon
{
    CGPoint center = [self convertPoint:self.center fromView:self.superview];
    self.iconImageView.center = center;
    center.y += 25;
    self.descriptionLabel.center = center;
}

- (void)choseImage
{
    if (self.image){
        [self.iconImageView removeFromSuperview];
        self.iconImageView = nil;
        
        [self.descriptionLabel removeFromSuperview];
        self.descriptionLabel = nil;
        
        self.layer.borderWidth = 0;
        //self.backgroundColor = [UIColor clearColor];
        
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
