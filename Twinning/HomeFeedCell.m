//
//  HomeFeedCell.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/18/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeFeedCell.h"
#import "constants.h"
#import "UIColor+HexValue.h"

@implementation HomeFeedCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    CGSize size = self.subImageView.frame.size;
    self.subImageView.layer.borderWidth = 1.f;
    self.subImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.subImageView.layer.cornerRadius = size.width/2;
    self.subImageView.layer.masksToBounds = YES;
    
    self.mainImageView.layer.masksToBounds = YES;
    
    UIImageView *timeAgoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTimeAgoLogo]];
    timeAgoImage.frame = CGRectMake(20,1, 10, 10);
    
    [self.timeAgoLabel addSubview:timeAgoImage];
    [self setupColor];
    
}

- (void)setupColor
{
    self.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [UIColor lightGrayColor];
    self.selectedBackgroundView = tappedBackgroundColor;
    
    for (UIView *view in self.contentView.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            ((UILabel *)view).textColor = [UIColor whiteColor];
        }
    }
    
}


@end
