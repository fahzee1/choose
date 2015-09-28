//
//  ShareScreenCell.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/28/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ShareScreenCell.h"

@implementation ShareScreenCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    CGSize size = self.leftIconImage.frame.size;
    self.leftIconImage.layer.borderWidth = 1.f;
    self.leftIconImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.leftIconImage.layer.cornerRadius = size.width/2;
    self.leftIconImage.layer.masksToBounds = YES;
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
