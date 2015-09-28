//
//  UIImage+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;

+(UIImage *) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

-(UIImage *)drawWatermarkText:(NSString*)text;

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;

+(UIImage*)imageCrop:(UIImage*)original;

- (UIImage *)compressImage:(UIImage *)image;

@end
