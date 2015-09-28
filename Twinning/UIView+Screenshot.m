//
//  UIView+Screenshot.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)


-(UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



// dont use
-(UIImage *)snapshotView:(UIView *)view
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}
@end
