//
//  SearchCell.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "SearchCell.h"
#import "constants.h"
#import "UIColor+HexValue.h"


@implementation SearchCell

- (void)awakeFromNib {
    // Initialization code
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.layer.masksToBounds = YES;
    
    self.nameLabel.font = [UIFont fontWithName:kFontGlobal size:18];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
