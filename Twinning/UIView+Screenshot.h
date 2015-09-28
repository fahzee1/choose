//
//  UIView+Screenshot.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Screenshot)


-(UIImage *)convertViewToImage;


// dont use
-(UIImage *)snapshotView:(UIView *)view;

@end
