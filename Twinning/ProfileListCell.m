//
//  ProfileListCell.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ProfileListCell.h"
#import "constants.h"
#import "UIColor+HexValue.h"

@implementation ProfileListCell

- (void)awakeFromNib {
    // Initialization code
    
    self.cardTitle.font = [UIFont fontWithName:kFontGlobal size:17];
    self.cardDate.font = [UIFont fontWithName:kFontGlobal size:14];
    self.cardDate.textColor = [UIColor colorWithHexString:kColorDarkGrey];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
