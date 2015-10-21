//
//  MenuCell.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "MenuCell.h"
#import "UIColor+HexValue.h"
#import "constants.h"

@implementation MenuCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.selectedBackgroundView = tappedBackgroundColor;
    self.name.textColor = [UIColor whiteColor];
    self.name.font = [UIFont fontWithName:kFontGlobal size:15];
}
@end
