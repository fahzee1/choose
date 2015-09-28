//
//  UIView+MyInfo.m
//  Captify
//
//  Created by CJ Ogbuehi on 7/30/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UIView+MyInfo.h"
#import <objc/runtime.h>

@implementation UIView (MyInfo)

-(void)setMyInfo:(id)info
{
    objc_setAssociatedObject( self, "_myInfo", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC ) ;
}

-(id)myInfo
{
    return objc_getAssociatedObject( self, "_myInfo" ) ;
}

@end
