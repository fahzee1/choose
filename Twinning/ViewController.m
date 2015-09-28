//
//  ViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/12/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ViewController.h"
#import "EasyFacebook.h"
#import <MBProgressHUD.h>
#import "APIClient.h"

@interface ViewController ()
@property (strong,nonatomic) MBProgressHUD *hud;

// This is to verify we're attempting to login with fbook
@property BOOL facebookIsLoggingIn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenForNotifs];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)listenForNotifs
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFacebookLogin:)
                                                 name:EasyFacebookUserInfoFetchedNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(markFacebookLogin)
                                                 name:EasyFacebookLoggedInNotification object:nil];
    
}

- (IBAction)logOut:(UIButton *)sender {
    [[EasyFacebook sharedEasyFacebookClient] logOut];
}

- (IBAction)tappedFacebook:(UIButton *)sender {
    if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn]){
        // skip facebook stuff and just login as usual
       
    
        [self dismissViewControllerAnimated:YES completion:nil];
        
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
        NSString *firstname = sender.UserFirstName;
        NSString *lastname = sender.UserLastName;
        NSString *username = sender.UserName;
        NSString *email = sender.UserEmail;
        NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbuserid = [FBSDKAccessToken currentAccessToken].userID;
        
        NSMutableDictionary *oauth = [@{}mutableCopy];
        
        if (fbuserid){
            oauth[@"facebook_id"] = fbuserid;
        }
        
        if (email){
            oauth[@"email"] = email;
        }
        
        if (token){
            oauth[@"token"] = token;
        }
        if (firstname){
            oauth[@"first_name"] = firstname;
        }
        
        if (lastname){
            oauth[@"last_name"] = lastname;
        }
        
        oauth[@"age"] = @"0";
        
        
        
        NSLog(@"need to send this data to server : %@",oauth);
        
        [self loginWithParams:oauth
                        block:^(bool success, id data) {
                            if (success){
                                UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
                                [self.navigationController pushViewController:controller animated:YES];
                                
                            }
                            else{
                                [self showMessageWithTitle:@"Error" andMessage:@"Issue"];
                            }
                        }];
        
        /*
        [User loginWithParams:data block:^(APIRequestStatus status, NSString *userToken) {
            if (status == APIRequestStatusSuccess){
                // make sure to grab authkey and set in defaults
                self.localUser.username = username;
                self.localUser.fbUser = [NSNumber numberWithBool:YES];
                self.localUser.fbID = fbuserid;
                self.localUser.firstname = firstname;
                self.localUser.lastname = lastname;
                self.localUser.email = email;
                self.localUser.loggedIn = [NSNumber numberWithBool:YES];
                self.localUser.fbToken = token;
                if (userToken){
                    [self saveLocalUserToken:userToken];
                }
                [self.localUser.managedObjectContext save:nil];
                
                if ([self.delegate respondsToSelector:@selector(controller:loggedInUser:)]){
                    [self.delegate controller:self loggedInUser:self.localUser];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                
                
            }
            else{
                [self.hud hide:YES];
                [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"There was an error logging you in. Please try again.", nil)];
            }
        }];
        */
    }
    
}

typedef void (^ResponseBlock) (bool success, id data);

- (void)loginWithParams:(NSDictionary *)params
                  block:(ResponseBlock)block
{
    APIClient *client = [APIClient sharedClient];
    [client startNetworkActivity];
    
    [client POST:APILoginString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [self.hud hide:YES];
             [client stopNetworkActivity];
             
             int success = [responseObject[@"success"] intValue];
             if (success){
                 if (block){
                     block(YES,responseObject);
                 }

             }
             else{
                 if (block){
                     block(NO,nil);
                 }

             }
                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
             [self.hud hide:YES];
             [client stopNetworkActivity];
             NSLog(@"%@",error.localizedDescription);
             if (block){
                 block(NO,nil);
             }
         }];
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
