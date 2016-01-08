//
//  AppDelegate.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/12/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ChooseViewController.h"
#import "EasyFacebook.h"
#import "constants.h"
#import <Bolts.h>
#import "UIColor+HexValue.h"
#import "MenuViewController.h"
#import <ECSlidingViewController.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Branch.h>
#import <MMAdSDK/MMAdSDK.h>
#import <Parse/Parse.h>
#import <LaunchKit/LaunchKit.h>
#import "MMConversionTracking.h"
#import <CRToast.h>
#import <TestFairy.h>


@interface AppDelegate ()
@property (assign) BOOL appInForeground;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Global appearance
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithHexString:kColorRed]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:kColorRed]];
    if (IS_IOS8){
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                           NSFontAttributeName:[UIFont fontWithName:kFontGlobalBold size:20]}];
    
    
    // Menu setup
    // Right slide out menu setup
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *home = [mainStoryboard instantiateViewControllerWithIdentifier:kStoryboardHomeRoot];
    MenuViewController *menu = [mainStoryboard instantiateViewControllerWithIdentifier:kStoryboardMenu];
    ECSlidingViewController *slideController = [ECSlidingViewController slidingWithTopViewController:home];
    slideController.underLeftViewController = menu;
    [self.window makeKeyAndVisible];
    self.window.rootViewController = slideController;
    
    
    
    //Facebook stuff
    [EasyFacebook application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
        
    } else {
        // use registerForRemoteNotificationTypes:
        
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]){
        self.appInForeground = YES;
    }
    
    
    NSString *email = [defaults valueForKey:kEmail]? [defaults valueForKey:kEmail]:@"no email";
    NSString *name = [defaults valueForKey:kUsername]? [defaults valueForKey:kUsername]:@"no username";
    NSString *id = [defaults valueForKey:kID]? [defaults valueForKey:kID]:@"no id";
    
    // Test Fairy
    [TestFairy begin:@"02b065755555f2259f81ff722e6f11d86749b2dc"];
    [TestFairy identify:id
                 traits:@{TFSDKIdentityTraitEmailAddressKey:email,
                          TFSDKIdentityTraitNameKey:name}];
    

    // Fabric
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];
    [CrashlyticsKit setUserIdentifier:id];
    [CrashlyticsKit setUserEmail:email];
    [CrashlyticsKit setUserName:name];


    // Branch
    Branch *branch = [Branch getInstance];
    ChooseViewController *chooseController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kStoryboardChoose];
    [branch registerDeepLinkController:chooseController forKey:@"card_id"];
    
    [branch initSessionAndAutomaticallyDisplayDeepLinkController:YES deepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        NSLog(@"deep link data: %@", [params description]);
        
        if (!params[@"is_first_session"]){
            // send out notification (with delay so appropriate controller is created to hear it)
            // that alerts of new user from click
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBranchFirstTimeUser object:self];
            });
        }
    }];
    
    // LaunchKit stuff
    [LaunchKit launchWithToken:@"DiYB1vCSfS1WiUzE_9zbPkDpZoC45i-fEop21kIthYDY"];
    
    // Parse stuff
    [Parse setApplicationId:@"Jnloet4uKj9z5hJOaVdiIKRRrOzLCUf1COzse16Z"
                  clientKey:@"6fzZZrLQXphwTtFlB1gY36hSgTEYeFqwkIFjLEsg"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"Choose" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    
    // Millennial Media (ads)
    MMAppSettings *appSettings = [[MMAppSettings alloc] init];
    appSettings.mediator = @"Facebook";
    
    //MMUserSettings* userSettings = [[MMUserSettings alloc] init];
    // Provide userSettings values here, as appropriate
    
    [[MMSDK sharedInstance] initializeWithSettings:appSettings withUserSettings:nil];
    //[MMConversionTracking trackConversionWithGoalId:@"YOUR_APP_TRACKING_ID"];
    
    
    // Create initial user
    if (![defaults boolForKey:kLocalUserCreated]){
        [User createLocalUserInContext:self.managedObjectContext];
        [defaults setBool:YES forKey:kLocalUserCreated];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[Branch getInstance] handleDeepLink:url];
    
    BOOL wasHandled1 = [EasyFacebook application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData]){
        NSURL *targetUrl = [parsedUrl targetURL];
        DLog(@"facebook invite target url is %@",[targetUrl absoluteString]);
    }
    return wasHandled1;
}

// Push Notification code
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                       ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                       ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                       ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    DLog(@"Token is %@... do something with it",token);
    
    // Save to parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"Did Fail to Register for Remote Notifications");
    DLog(@"%@, %@", error, error.localizedDescription);
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self notifyReceivedRemoteNotificationWithData:userInfo foreground:self.appInForeground];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.genysolutions.Twinning" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Twinning" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Twinning.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Push Notifications

- (void)notifyReceivedRemoteNotificationWithData:(NSDictionary *)data
                                      foreground:(BOOL)foreground
{
    // Notify home controller that a notification came in
    //NSMutableDictionary *mutableData = [data mutableCopy];
    //mutableData[@"foreground"] = [NSNumber numberWithBool:foreground];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRecievedRemoteNotification object:self userInfo:mutableData];
    
    //NSString *styleName = @"basicNotification";
    NSString *alert = data[@"aps"][@"alert"];
    DLog(@"do something with (%@)",alert);
    
    NSDictionary *options = @{
                              kCRToastTextKey :alert,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor colorWithHexString:kColorFlatTurquoise],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                              kCRToastTextColorKey:[UIColor whiteColor],
                              kCRToastFontKey:[UIFont fontWithName:kFontGlobalBold size:18],
                              kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                }];

    
}

#pragma mark - App delegate custom
+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}



@end
