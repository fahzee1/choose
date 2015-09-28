//
//  UIColor+HexValue.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/11/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexValue)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
