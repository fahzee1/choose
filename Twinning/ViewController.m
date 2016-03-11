//
//  ViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/12/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ViewController.h"
#import "EasyFacebook.h"
#import "constants.h"
#import "UIColor+HexValue.h"
#import <MBProgressHUD.h>
#import "APIClient.h"
#import <Onboard/OnboardingViewController.h>
#import <ChameleonFramework/Chameleon.h>
#import "SDVersion.h"

@interface ViewController ()
@property (strong,nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *skipLoginButton;
@property (strong, nonatomic) OnboardingViewController *onboard;

@property (weak, nonatomic) IBOutlet UILabel *facebookInfoLabel;

// This is to verify we're attempting to login with fbook
@property BOOL facebookIsLoggingIn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenForNotifs];
    [self setup];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupOnBoardScreens];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.navigationController.navigationBarHidden = YES;
    UIColor *red = [UIColor colorWithHexString:kColorRed];
    UIColor *green = [UIColor colorWithHexString:kColorFlatGreen];
    UIColor *white = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.frame andColors:@[green,red,white]];
    
    
    self.skipLoginButton.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    [self.skipLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.skipLoginButton setTitle:NSLocalizedString(@"Skip Login", nil) forState:UIControlStateNormal];
    
    self.facebookInfoLabel.font = [UIFont fontWithName:kFontGlobalBold size:15];
    [self.facebookInfoLabel setTextColor:[UIColor whiteColor]];
    self.facebookInfoLabel.text = NSLocalizedString(@"Facebook is only used to create an account with Choose. We will not be collecting your email or posting anything to your account", nil);
}
- (void)listenForNotifs
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFacebookLogin:)
                                                 name:EasyFacebookUserInfoFetchedNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markFacebookLogin)
                                                 name:EasyFacebookLoggedInNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissLoginController)
                                                 name:kNotificationOnboardIsOver object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (IBAction)tappedSkipLogin:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"loggedIn"];
    [defaults setBool:YES forKey:kAnonymousUser];
    [defaults setValue:kAnonymousUser forKey:kLocalUserAuthKey];
    self.localUser.anonymous = [NSNumber numberWithBool:YES];
    [self.localUser.managedObjectContext save:nil];
    
    
    [self showOnBoardScreens];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logOut:(UIButton *)sender {
    [[EasyFacebook sharedEasyFacebookClient] logOut];
}

- (IBAction)tappedFacebook:(UIButton *)sender {
    if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn]){
        // skip facebook stuff and just login as usual
        [[EasyFacebook sharedEasyFacebookClient] logOut];
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"Logged you out of old Facebook session. Please try again", nil)];
        
    }
    
    else if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn]){
        [[EasyFacebook sharedEasyFacebookClient] logOut];
        [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"There was an error logging you in. Please try again.", nil)];
    }
    else{
        [EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends"];
        [[EasyFacebook sharedEasyFacebookClient] logIn];
        
    }

}

- (void)markFacebookLogin
{
    // Used to keep track if we're logging in with fbook or not (method below)
    self.facebookIsLoggingIn = YES;
}

- (void)handleFacebookLogin:(NSNotification *)notif
{
    if (self.facebookIsLoggingIn){
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.labelText = NSLocalizedString(@"Logging In..", nil);
        
        EasyFacebook *sender = notif.object;
        NSString *username = sender.UserName;
        NSString *email = sender.UserEmail;
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *facebook_id = [FBSDKAccessToken currentAccessToken].userID;
        
        NSMutableDictionary *oauth = [@{}mutableCopy];
        
        if (facebook_id){
            oauth[@"facebook_id"] = facebook_id;
        }
        
        if (email){
            oauth[@"email"] = email;
        }
        
        if (token){
            oauth[@"token"] = token;
        }
    
        if (username){
            oauth[@"name"] = username;
        }
        
        
        
        NSLog(@"need to send this data to server : %@",oauth);
        
        [self loginWithParams:oauth
                        block:^(APIRequestStatus status, id data) {
                            if (status == APIRequestStatusSuccess){
                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                [defaults setBool:YES forKey:@"loggedIn"];
                                NSString *token = data[@"data"][@"user"][@"auth_token"];
                                [defaults setValue:token forKey:kLocalUserAuthKey];
                                [defaults setBool:NO forKey:kAnonymousUser];
                                self.localUser.anonymous = [NSNumber numberWithBool:NO];
                                self.localUser.name = username;
                                self.localUser.facebook_id = facebook_id;
                                self.localUser.logged_in = [NSNumber numberWithBool:YES];
                                if (email){
                                    self.localUser.email = email;
                                }
                                [self.localUser.managedObjectContext save:nil];
                                
                                [self showOnBoardScreens];
                                
                            }
                            else{
                                [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"There was an error creating an account. Please try again.", nil)];
                            }
                        }];
        
    }
    
}

typedef void (^ResponseBlock2) (bool success, id data);

- (void)loginWithParams:(NSDictionary *)params
                  block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APILoginString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             [self.hud hide:YES];
             if (block){
                 block(APIRequestStatusSuccess,responseObject);
             }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             [self.hud hide:YES];
             if (block){
                 block(APIRequestStatusFail,@{});
             }
         }];
}

- (void)setupOnBoardScreens
{
    OnboardingContentViewController *firstPage = [OnboardingContentViewController
                                                  contentWithTitle:@"Welcome To Choose"
                                                  body:@"Check out questions asked by the community like the one above. Curated everyday at 12 pm."
                                                  image:[UIImage imageNamed:kImageCard2]
                                                  buttonText:nil action:^{
                                                      DLog(@"tapped button");
                                                  }];
    firstPage.movesToNextViewController = YES;
    OnboardingContentViewController *secondPage = [OnboardingContentViewController
                                                   contentWithTitle:@"The Choice Is Yours"
                                                   body:@"Choose A or B or choose Yes or No, then see what your peers think."
                                                   image:[UIImage imageNamed:kImageCard3]
                                                   buttonText:nil action:^{
                                                       DLog(@"tapped button");
                                                       
                                                   }];
    secondPage.movesToNextViewController = YES;
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController
                                                  contentWithTitle:@"Create Your Own"
                                                  body:@"Why not get in on the fun? Submit your questions and get instant feedback!"
                                                  image:[UIImage imageNamed:kImageCard4]
                                                  buttonText:@"Tap to start!" action:^{
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnboardIsOver object:self];
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                      
                                                  }];
    
    
    self.onboard = [OnboardingViewController
                    onboardWithBackgroundImage:[UIImage imageNamed:@"cedric"]
                    contents:@[firstPage,secondPage,thirdPage]];
    self.onboard.shouldBlurBackground = YES;
    self.onboard.shouldFadeTransitions = YES;
    self.onboard.titleFontSize = 20;
    self.onboard.titleFontName = kFontGlobalBold;
    self.onboard.bodyFontSize = 16;
    self.onboard.bodyFontName = kFontGlobal;
    self.onboard.buttonFontName = kFontGlobalBold;
    self.onboard.buttonFontSize = 17;
    self.onboard.topPadding = 10;
    self.onboard.iconSize = 300;
    
    switch ([SDVersion deviceVersion]) {
        case iPad1:
        {
            [self addBottomPadding];
        }
            break;
        case iPad2:
        {
            [self addBottomPadding];
        }
            break;
        case iPad3:
        {
            [self addBottomPadding];
        }
            break;
        case iPad4:
        {
            [self addBottomPadding];
        }
            break;
        case iPadAir:
        {
            [self addBottomPadding];
        }
            break;
        case iPadAir2:
        {
            [self addBottomPadding];
        }
            break;
        case iPadMini:
        {
            [self addBottomPadding];
        }
            break;
        case iPadMini2:
        {
            [self addBottomPadding];
        }
            break;
        case iPadMini3:
        {
            [self addBottomPadding];
        }
            break;
        case iPadMini4:
        {
            [self addBottomPadding];
            
        }
            break;
        case iPadPro:
        {
            [self addBottomPadding];
        }
            break;
        default:
        {
            DLog(@"default here");
        }
            break;
    }

}

- (void)addBottomPadding
{
    self.onboard.topPadding = 5;
    self.onboard.underIconPadding = 0;
    self.onboard.underTitlePadding = 0;
    self.onboard.bottomPadding = 0;
}

- (void)showOnBoardScreens
{
    if (self.onboard){
        [self presentViewController:self.onboard animated:YES completion:nil];
    }
    else{
        [self setupOnBoardScreens];
        [self showOnBoardScreens];
    }
}

- (void)dismissLoginController
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}


@end
