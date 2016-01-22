//
//  constants.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/12/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#ifndef Twinning_constants_h
#define Twinning_constants_h


#endif

// useful stuff
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define IS_IOS8 ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]?YES:NO)

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"Elapsed Time: %f", -[startTime timeIntervalSinceNow])

typedef NS_ENUM(NSInteger, UserStatus){
    UserStatusLoggedIn = 100,
    UserStatusAnonymous
};
static NSString *const kChooseEmail = @"cj@trychoose.com";
static NSString *const kLocalAppID = @"1072816125";
static NSString *const kLocalUser = @"localuser";
static NSString *const kLocalUserAuthKey = @"localauthkey";
static NSString *const kLocalUserCreated = @"kLocalUserCreated";
static NSString *const kInstagramUserName = @"cj_o32";
static NSString *const kFacebookPageID = @"1498069333826125";
static NSString *const kFacebookPageName = @"trychoose";
static NSString *const kFlickrHostedImage = @"http://images.trychoose.com/static/choose-iphone-example.jpg";
static NSString *const kServerShareTextID = @"kServerShareTextID";
static NSString *const kAnonymousUser = @"anonymous";

static NSString *const kEmail = @"kEmail";
static NSString *const kUsername = @"kUsername";
static NSString *const kID = @"kID";

// Colors
static NSString *const kColorRed = @"#ef2b2b";
static NSString *const kColorLightGrey = @"#ececec";
static NSString *const kColorDarkGrey = @"#9e9e9e";
static NSString *const kColorOrange = @"#ff7300";
static NSString *const kColorFlatRed = @"#e74c3c";
static NSString *const kColorFlatGreen = @"#2ecc71";
static NSString *const kColorFlatBlue = @"#3498db";
static NSString *const kColorFlatNavyBlue = @"#34495e";
static NSString *const kColorFlatTurquoise = @"#1abc9c";
static NSString *const kColorFlatOrange = @"#f39c12";
static NSString *const kColorFlatPurple = @"#9b59b6";
static NSString *const kColorFacebook = @"#3b5998";
static NSString *const kColorInstagram = @"#125688";
static NSString *const kColorTwitter = @"#00aced";
static NSString *const kColorBlackSexy = @"#343434";

// Fonts
static NSString *const kFontGlobal = @"ProximaNova-Semibold";
static NSString *const kFontGlobalBold = @"ProximaNova-Bold";
static NSString *const kFontSilly = @"GoodDog";

// Storyboards
static NSString *const kStoryboardMenu = @"menu";
static NSString *const kStoryboardHome = @"home";
static NSString *const kStoryboardHomeRoot = @"homeRoot";
static NSString *const kStoryboardLogin = @"login";
static NSString *const kStoryboardCreateVote = @"create";
static NSString *const kStoryboardCreateVoteRoot = @"createRoot";
static NSString *const kStoryboardShare = @"share";
static NSString *const kStoryboardSearch = @"search";
static NSString *const kStoryboardProfile = @"profile";
static NSString *const kStoryboardCard = @"card";
static NSString *const kStoryboardChoose = @"choose";
static NSString *const kStoryboardADPlacement = @"adPlacement";
static NSString *const kStoryboardFullScreen = @"fullScreen";

// Images
static NSString *const kBannerLogo = @"logo";
static NSString *const kTimeAgoLogo = @"clock-logo";
static NSString *const kUploadIcon = @"upload-a-photo-button";
static NSString *const kSelfieIcon = @"take-a-selfie-button";
static NSString *const kAppIcon = @"app-icon";
static NSString *const kAppPlaceholer = @"placeholder";

// Notifications
static NSString *const kNotificationBranchFirstTimeUser = @"kNotificationBranchFirstTimeUser";
static NSString *const kNotificationMenuTappedSearch = @"kNotificationMenuTappedSearch";
static NSString *const kNotificationMenuTappedCategoryChoice = @"kNotificationMenuTappedCategoryChoice";
static NSString *const kNotificationMenuTappedAccountChoice = @"kNotificationMenuTappedAccountChoice";
static NSString *const kNotificationMenuTappedSupportChoice = @"kNotificationMenuTappedSupportChoice";
static NSString *const kNotificationSubmittedCard = @"kNotificationSubmittedCard";
static NSString *const kNotificationShowingADPlacement = @"kNotificationShowingADPlacement";
static NSString *const kNotificationClosedADPlacement = @"kNotificationClosedADPlacement";
static NSString *const kNotificationOnboardIsOver = @"kNotificationOnboardIsOver";
static NSString *const kNotificationShowShareImageTip = @"kNotificationShowShareImageTip";
static NSString *const kNotificationLogOut = @"kNotificationLogOut";
static NSString *const kNotificationUserTrackingReady = @"kNotificationUserTrackingReady";
static NSString *const kNotificationShowCardWithId = @"kNotificationShowCardWithId";

// Default images
static NSString *const kImageCard = @"card";
static NSString *const kImageCard2 = @"card2";
static NSString *const kImageCard3 = @"results";
static NSString *const kImageCard4 = @"create";

