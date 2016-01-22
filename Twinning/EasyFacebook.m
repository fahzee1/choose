
#import "EasyFacebook.h"

@interface EasyFacebook ()<FBSDKSharingDelegate,FBSDKAppInviteDialogDelegate>
    
@end


@implementation EasyFacebook

+ (void)load
{
    [EasyFacebook sharedEasyFacebookClient];
}

+ (EasyFacebook *)sharedEasyFacebookClient
{
    static EasyFacebook *_sharedEasyFacebookClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEasyFacebookClient = [[self alloc] init];
        
        //Default settings
        _sharedEasyFacebookClient.readPermissions = @[@"public_profile", @"email", @"user_friends"];
        _sharedEasyFacebookClient.preventAppShutDown = NO;
        
        //Notifications
        [[NSNotificationCenter defaultCenter] addObserver:_sharedEasyFacebookClient
                                                 selector:@selector(appAutoLogon)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedEasyFacebookClient
                                                 selector:@selector(fixiOSShuttingDownAppProblem)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        
        
    });
    
    return _sharedEasyFacebookClient;
}

#pragma mark Login Manager

- (FBSDKLoginManager *)loginManger
{
    return [[FBSDKLoginManager alloc] init];
}

#pragma mark Handle UIApplication Notifications

- (void) appAutoLogon
{
    /*
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:self.readPermissions
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }
         ];
        
    }
     */
    
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    // When someone opens the app check if login token is there
    if (token){
        //if it is just use token silently
        NSLog(@"facebook user and we have active token");
        
    }
  
}

+ (BOOL)application:(UIApplication *) application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}


/*
//Add a handler to this method in AppDelegate - (BOOL)application:openURL:sourceApplication:annotation:
+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler: ^(FBSession *session, FBSessionState state, NSError *error) {
        [[EasyFacebook sharedEasyFacebookClient] sessionStateChanged:session state:state error:error];
    }];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
 */

#pragma mark - Permissions

- (BOOL)isPublishPermissionsAvailableQuickCheck
{
    if (![self isLoggedIn]){
        return NO;
    }
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]){
        return YES;
    }
    else{
        return NO;
    }

}



- (void)requestPublishPermissions:(void(^)(BOOL granted, NSError *error))responseHandler
{
    if (![self isLoggedIn])
    {
        if (responseHandler != nil)
            dispatch_async(dispatch_get_main_queue(), ^{ responseHandler(NO, nil); });
        return;
    }
    
    // Request publish_actions
    [[self loginManger] logInWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (!error){
            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    
            if (![token hasGranted:@"publish_actions"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookPublishPermissionDeclinedNotification object:self];
                if (responseHandler != nil) dispatch_async(dispatch_get_main_queue(), ^{ responseHandler(NO, nil); });
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookPublishPermissionGrantedNotification object:self];
                if (responseHandler != nil) dispatch_async(dispatch_get_main_queue(), ^{ responseHandler(YES, nil); });
            }
        }
        else{
            if (responseHandler != nil) dispatch_async(dispatch_get_main_queue(), ^{ responseHandler(NO, error); });
            // There was an error, handle it
            // See https://developers.facebook.com/docs/ios/errors/
            
        }

    }];
    
}

#pragma mark Actions

/*
- (void)publishStoryWithParams:(NSDictionary *)params completion:(void(^)(BOOL success, NSError *error))completion
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentDescription = @"description";
    
    FBSDKShareAPI *api = [FBSDKShareAPI shareWithContent:content delegate:self];
    [api share];
    
    
    if (![self isLoggedIn])
    {
        if (completion != nil)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               completion(NO, nil);
                           });
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
        [self.delegate showLoadingScreen:self];
    
    //Request Publish Permissions (don't bother checking first - as per fb example)
    __weak typeof(self) weakSelf = self;
    [self requestPublishPermissions:^(BOOL granted, NSError *error) {
        if (!error)
        {
            if (granted)
            {
                //Granted so now share story
                [FBRequestConnection startWithGraphPath:@"/me/feed"
                                             parameters:params
                                             HTTPMethod:@"POST"
                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                          if (!error)
                                          {
                                              // Link posted successfully to Facebook
//                                              NSLog(@"post success result: %@", result);
                                              [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookStoryPublishedNotification object:self];
                                              if (completion != nil) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES, nil); });
                                          }
                                          else
                                          {
                                              
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"%@", error.description);
                                              if (completion != nil) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, error); });
                                          }
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                                                  [weakSelf.delegate hideLoadingScreen:weakSelf];
                                          });
                                      }];
                
            }
            else
            {
                //Permission not granted
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                        [weakSelf.delegate hideLoadingScreen:weakSelf];
                });
                if (completion != nil) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, nil); });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                    [weakSelf.delegate hideLoadingScreen:weakSelf];
            });
            if (completion != nil) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, error); });
        }
    }];
}
 */

#pragma mark User Information Methods

- (void) clearUserDetails
{
    self.UserEmail = nil;
    self.UserFirstName = nil;
    self.UserGender = nil;
    self.UserObjectID = nil;
    self.UserLastName = nil;
    self.UserLink = nil;
    self.UserLocale = nil;
    self.UserName = nil;
    self.UserTimeZone = nil;
    self.UserVerified = nil;
}


- (void)fetchUserInformation
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error){
            NSLog(@"user info: %@", result);
            self.UserEmail = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"email"]];
            self.UserFirstName = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"""first_name"""]];
            self.UserGender = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"gender"]];
            self.UserObjectID = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"id"]];
            self.UserLastName = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"""last_name"""]];
            self.UserLink = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"link"]];
            self.UserLocale = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"locale"]];
            self.UserName = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"name"]];
            self.UserTimeZone = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"timezone"]];
            self.UserVerified = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"verified"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookUserInfoFetchedNotification object:self];
        }
        else{
            [self clearUserDetails];
        }
    }];
    
}

#pragma mark Logging On/Out

- (void)logIn
{
    // ex. [EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (!token){
        [[self loginManger] logInWithReadPermissions:self.readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [self loginStateChangeWithResult:result error:error];
        }];
    }
    
}


- (void)logOut
{
    [[self loginManger] logOut];
  
    
}

- (BOOL)isLoggedIn
{
   
    
    if ([FBSDKAccessToken currentAccessToken]){
        
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)isLoggedOut
{
    if (![FBSDKAccessToken currentAccessToken])
        return YES;
    else
        return NO;
}

 -(void)inviteFriendsFromController:(UIViewController *)controller
{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/216976028635544"];
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://images.trychoose.com/static/choose-facebook-add.png"];
    
    [FBSDKAppInviteDialog showFromViewController:controller
                                     withContent:content
                                        delegate:self];
}


#pragma mark Diagnostics

- (void) fixiOSShuttingDownAppProblem
{
    if (self.preventAppShutDown)
    {
        __block UIBackgroundTaskIdentifier background_task;
        
        background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            //Clean up code. Tell the system that we are done.
            [[UIApplication sharedApplication] endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
    }
}



#pragma mark State Change Controller

- (void)loginStateChangeWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    //if login was successful
    if (!error && result.token){
        NSLog(@"New login session opened");
        [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookLoggedInNotification object:self];
        [self fetchUserInformation];
        return;

    }
    
    // if user logged out send notif
    if ([self isLoggedOut]){
        if (!error){
            NSLog(@"login session closed");
            [self clearUserDetails];
            [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookLoggedOutNotification object:self];
        }
        
    }
    
    // if user cancelled do nothing
    if (error && result.isCancelled){
        NSLog(@"User cancelled login");
        [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookUserCancelledLoginNotification object:self];

        
    }
    
    if (error){
        
        NSLog(@"Error %@",error);
        NSString *alertText = error.localizedDescription;
        NSString *alertTitle = NSLocalizedString(@"Facebook Error", nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertText
                                                           delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        
        [self logOut];

    }
    
    
    
    
    
    
}

/*
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    
    // Handle errors
    if (error)
    {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = [[NSString alloc] initWithFormat:@"%@ Error",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
            alertText = [FBErrorUtility userMessageForError:error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:alertText
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
        else
        {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
//                NSLog(@"User cancelled login");
                [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookUserCancelledLoginNotification object:self];
                
                
            }// Handle session closures that happen outside of the app
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = [[NSString alloc] initWithFormat:@"%@ Error",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
                alertText = @"Your current session is no longer valid. Please log in again.";
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                    message:alertText
                                                                   delegate:nil cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = [[NSString alloc] initWithFormat:@"%@ Error",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                    message:alertText
                                                                   delegate:nil cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
        }
        
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
//        [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookLoggedOutNotification object:self];
    }
}

*/

#pragma mark Cleanup
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark FBSDKAppInvite delegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"completed with results %@",results);
    [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookInviteSuccessNotification object:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    NSLog(@"error %@",error.localizedDescription);
    [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookInviteFailNotification object:self];
}

#pragma mark FBSDK delegate
-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    // Link posted successfully to Facebook
    NSLog(@"post success result: %@", results);
    [[NSNotificationCenter defaultCenter] postNotificationName:EasyFacebookStoryPublishedNotification object:self];

}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    
}


@end