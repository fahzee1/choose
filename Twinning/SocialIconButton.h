//
//  SocialIconButton.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/9/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SocialButton){
    SocialButtonTwitter,
    SocialButtonFacebook,
    SocialButtonInstagram,
    SocialButtonMore
    
};
@interface SocialIconButton : UIButton

@property (assign, nonatomic) SocialButton type;
@end
