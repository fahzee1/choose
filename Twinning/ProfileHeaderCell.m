//
//  ProfileHeaderCell.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ProfileHeaderCell.h"
#import "constants.h"
#import "UIColor+HexValue.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@implementation ProfileHeaderCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    self.profileImageView.layer.masksToBounds = YES;
    
    self.profileLabel.font = [UIFont fontWithName:kFontGlobal size:18];
    
    FAKIonIcons *personIcon = [FAKIonIcons personIconWithSize:45];
    [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    personIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatRed];
    UIImage *personImage = [personIcon imageWithSize:CGSizeMake(50, 50)];
    self.profileImageView.image = personImage;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
