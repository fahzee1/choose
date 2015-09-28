//
//  NSString+utils.m
//  Captify
//
//  Created by CJ Ogbuehi on 7/11/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "NSString+utils.h"

@implementation NSString (utils)


- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}
@end
