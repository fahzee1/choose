//
//  NSString+utils.h
//  Captify
//
//  Created by CJ Ogbuehi on 7/11/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (utils)
- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;
@end
