//
//  ShareScreenCell.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/28/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ShareScreenCell.h"
#import "UIColor+HexValue.h"
#import "constants.h"

@implementation ShareScreenCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    //CGSize size = self.leftIconImage.frame.size;
    self.leftIconImage.layer.borderWidth = 1.f;
    self.leftIconImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.leftIconImage.layer.cornerRadius = 5; //size.width/2;
    self.leftIconImage.layer.masksToBounds = YES;
    
    [self setupColor];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupColor
{
    self.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [UIColor colorWithHexString:kColorLightGrey];
    self.selectedBackgroundView = tappedBackgroundColor;
    
    for (UIView *view in self.contentView.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            ((UILabel *)view).textColor = [UIColor whiteColor];
        }
    }
    
}


@end
