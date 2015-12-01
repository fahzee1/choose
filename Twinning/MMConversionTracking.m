/**
 * The MIT License (MIT)
 
 Copyright (c) 2011 - 2014 Millennial Media
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 *
 */

//  MMConversionTracking.m
//  MMConversionTracking (Version 1.2.0)

#import "MMConversionTracking.h"
#import <UIKit/UIKit.h>

/**
 * Ad server URL
 */
static NSString * const kConversionServerURL = @"http://cvt.mydas.mobi/";

/**
 * Ad server conversion request query
 */
static NSString * const kConversionRequestQuery = @"handleConversion?";

#pragma mark - MAC Address

#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>

@implementation MMConversionTracking

+ (void)trackConversionWithGoalId:(NSString *)goalId {
    if (!goalId) {
		[NSException raise:@"Invalid goal id." format:@"Goal id must not be nil."];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *bundleID = [NSString stringWithFormat:@"%@_MMIRegister_%@", [self getAppIdentifier], goalId];
    NSLog(@"MILLENNIAL MEDIA - INFO: %@", bundleID);
    
    // Check if goal id has already been registered
	BOOL val = [defaults boolForKey:bundleID];
	NSString *firstlaunch = @"0";
	if (!val) {
        NSLog(@"MILLENNIAL MEDIA - INFO: GOAL ID FIRST RUN: %@", goalId);
		firstlaunch = @"1";
	}
    else {
        NSLog(@"MILLENNIAL MEDIA - INFO: GOAL ID RUN BEFORE: %@", goalId);
    }
    
    // Create the base URL from the ad server URL and conversion tracking query
    NSString *baseURLString = [kConversionServerURL stringByAppendingString:kConversionRequestQuery];
    
    // Create a dictionary of ad request parameters
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"goalid"] = goalId;
    parameters[@"firstlaunch"] = firstlaunch;
    [parameters addEntriesFromDictionary:[self requestParameters]];
    
    // Build a URL string from the base URL and our request parameters
    NSString *trackingUrlString = [baseURLString stringByAppendingString:[self queryStringFromParameters:parameters]];
    
    // Send the tracking request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSURLRequest *request = NSURLRequestFromString(trackingUrlString);
        NSURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // If no error occurs, register a successful conversion for the goal id
        if (!error) {
            [defaults setBool:YES forKey:bundleID];
            [defaults synchronize];
        }
        else {
            NSLog(@"MILLENNIAL MEDIA - ERROR: %@", [error localizedDescription]);
        }
    });
}

+ (NSDictionary *)requestParameters {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // Hashed advertising identifier
    NSString *haid = [self advertisingId:YES];
    if (haid) parameters[@"haid"] = haid;
    
    // Unhashed advertising identifier
    NSString *uaid = [self advertisingId:NO];
    if (uaid) parameters[@"uaid"] = uaid;
 
    //Ad Tracking Enabled
    if ([self isAdvertisingTrackingEnabled]) {
        parameters[@"ate"] = @"true";
    } else {
        parameters[@"ate"] = @"false";
    }
    
    // Bundle ID
    NSString *pkid = [self getAppIdentifier];
    if (pkid) parameters[@"pkid"] = pkid;
    
    // Bundle display name
    NSString *pknm = [self getAppDisplayName];
    if (pknm) parameters[@"pknm"] = pknm;
    
    // Screen width
    NSString *wpx = [NSString stringWithFormat:@"%f", [self screenWidth]];
    if (wpx) parameters[@"wpx"] = wpx;
    
    // Screen height
    NSString *hpx = [NSString stringWithFormat:@"%f", [self screenHeight]];
    if (hpx) parameters[@"hpx"] = hpx;
    
    // Density
    NSString *density = [NSString stringWithFormat:@"%f", [self density]];
    if (density) parameters[@"density"] = density;
    
    // Mobile Country Code
    NSString *mcc = [self mobileCountryCode];
    if (mcc) parameters[@"mcc"] = mcc;
    
    // Mobile Network Code
    NSString *mnc = [self mobileNetworkCode];
    if (mnc) parameters[@"mnc"] = mnc;
    
    // User language
    NSString *language = [self language];
    if (language) parameters[@"language"] = language;
    
    // User country
    NSString *country = [self country];
    if (country) parameters[@"country"] = country;
    
    // Device model
    NSString *dm = [self deviceModel];
    if (dm) parameters[@"dm"] = dm;
    
    // Operating system version
    NSString *dv = [self systemVersion];
    if (dv) parameters[@"dv"] = dv;
    
    // Firmware version
    NSString *firmwareVersion = [self firmwareVersion];
    if (firmwareVersion) parameters[@"firmware"] = firmwareVersion;
    
    // Platform
    NSString *platform = [self platform];
    if (platform) parameters[@"platform"] = platform;
    
    return parameters;
}

#pragma mark - Device properties

// pkid
+ (NSString *)getAppIdentifier {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

// pknm
+ (NSString *)getAppDisplayName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

// wpx
+ (CGFloat)screenWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

// hpx
+ (CGFloat)screenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

// density
+ (CGFloat)density {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		return [[UIScreen mainScreen] scale];
	}
	return 1.0;
}

// mcc
+ (NSString *)mobileCountryCode {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    return [[networkInfo subscriberCellularProvider] mobileCountryCode];
}

// mnc
+ (NSString *)mobileNetworkCode {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    return [[networkInfo subscriberCellularProvider] mobileNetworkCode];
}

// language
+ (NSString *)language {
    return [NSLocale preferredLanguages][0];
}

// country
+ (NSString *)country {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

// dm
+ (NSString *)deviceModel {
	NSString *deviceModel = nil;
	char buffer[32];
	size_t length = sizeof(buffer);
	if (sysctlbyname("hw.machine", &buffer, &length, NULL, 0) == 0) {
		deviceModel = [[NSString alloc] initWithCString:buffer encoding:NSASCIIStringEncoding];
	}
    return deviceModel;
}

// dv
+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

// firmware
+ (NSString *)firmwareVersion {
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *firmwareVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        firmwareVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding];
    }
    
    return firmwareVersion;
}

+ (NSString *)platform {
    return @"iOS";
}

#pragma mark - Advertising tracking

+ (BOOL)isAdvertisingTrackingEnabled {
    Class asIDManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (asIDManagerClass) {
        SEL sharedManagerSel = NSSelectorFromString(@"sharedManager");
        if ([asIDManagerClass respondsToSelector:sharedManagerSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id adManager = [asIDManagerClass performSelector:sharedManagerSel];
            if (adManager) {
                SEL isAdvertisingTrackingEnabledSel = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
                if ([adManager respondsToSelector:isAdvertisingTrackingEnabledSel]) {
                    BOOL returnValue = (BOOL)((uintptr_t)[adManager performSelector:isAdvertisingTrackingEnabledSel]);
#pragma clang diagnostic pop
                    return returnValue;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - HAID

// Apple's advertising identifier (hashed)
+ (NSString *)advertisingId:(BOOL)hashed {
    Class asIDManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (asIDManagerClass) {
        NSString *adId = nil;
        
        SEL sharedManagerSel = NSSelectorFromString(@"sharedManager");
        if ([asIDManagerClass respondsToSelector:sharedManagerSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id adManager = [asIDManagerClass performSelector:sharedManagerSel];
            if (adManager) {
                SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
                
                if ([adManager respondsToSelector:advertisingIdentifierSelector]) {
                    
                    id uuid = [adManager performSelector:advertisingIdentifierSelector];
                    
                    if (!uuid) {
                        return nil;
                    }
                    
                    SEL uuidStringSelector = NSSelectorFromString(@"UUIDString");
                    if ([uuid respondsToSelector:uuidStringSelector]) {
                        adId = [uuid performSelector:uuidStringSelector];
#pragma clang diagnostic pop
                    }
                }
            }
        }
        
        if (!adId) {
            return nil;
        }
        
        if (hashed) {
            //mmh_MD5_SHA1
            adId = [NSString stringWithFormat:@"mmh_%@_%@", [self md5:adId], [self sha1:adId]];
        }
        return adId;
    }
    
    return nil;
}

#pragma mark - Helper Methods

NSURLRequest *NSURLRequestFromString(NSString *string) {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
}

+ (NSString *)sha1:(NSString *)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", result[i]];
    }
    
    return output;
}

// URL encode each request parameter
+ (NSString *)urlEncode:(NSString *)urlString {
    static CFStringRef escapedCharacters = CFSTR(":/=,!$&'()*+;[]@#?");
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																				 (__bridge CFStringRef)urlString,
																				 NULL,
																				 escapedCharacters,
																				 kCFStringEncodingUTF8);
}

// Create a query string from the dictionary of parameters
+ (NSString *)queryStringFromParameters:(NSDictionary *)params {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params) {
        id value = params[key];
        if ([value isKindOfClass:[NSString class]]) {
            [parts addObject:[NSString stringWithFormat:@"%@=%@", key, [self urlEncode:value]]];
        }
        else {
            [parts addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    
    // Alphabetize parameters
    NSArray *sortedParts = [parts sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return [sortedParts componentsJoinedByString:@"&"];
}

@end
