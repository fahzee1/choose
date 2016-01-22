//
//  HomeViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "ChooseViewController.h"
#import "APIClient.h"
#import "ViewController.h"
#import "HomeFeedCell.h"
#import "HomeErrorView.h"
#import "EasyFacebook.h"
#import "UIView+MyInfo.h"
#import "ShareViewController.h"
#import "FullScreenImageViewController.h"
#import "ProfileViewController.h"
#import "CreateVoteController.h"
#import "ADPlacementViewController.h"
#import <UIViewController+ECSlidingViewController.h>
#import <AMPopTip.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "UIColor+HexValue.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <CRToast.h>
#import "HomeContainerView.h"
#import "Card.h"
#import "User+CoreDataProperties.h"
#import "AppDelegate.h"
#import "constants.h"
#import <MMAdSDK/MMAdSDK.h>
#import <MBProgressHUD.h>
#import <PSTAlertController.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <LaunchKit/LaunchKit.h>
#import <ChameleonFramework/Chameleon.h>
#import <PINCache.h>
#import <Parse/Parse.h>
#import <TestFairy.h>


@interface HomeViewController()<UIScrollViewDelegate,HomeContainerDelegate,MMInterstitialDelegate,FBInterstitialAdDelegate,HomeErrorViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *cardData;
@property (strong,nonatomic) NSMutableArray *cardData2;
@property (assign) NSInteger pageNumber;
@property (assign) NSInteger cardCount;
@property (strong,nonatomic) NSString *serverShareText;
@property (assign) CGPoint oldOffset;
@property (assign) BOOL showingAD;
@property (assign) BOOL stopServerFetch;
@property (assign) BOOL firstDataFetch;
@property (assign) BOOL firstPopTipShown;
@property (strong , nonatomic) AMPopTip *popTip;
@property (strong,nonatomic) User *localUser;
@property (strong, nonatomic) MMInterstitialAd *interstitialAd;
@property (strong, nonatomic) FBInterstitialAd *fbinterstitialAd;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) HomeErrorView *errorView;
@property (assign) UserStatus userStatus;


@end
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //get local user and set it
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserInContext:context];
    UIViewController *controller = self.slidingViewController.underLeftViewController;
    // pass local user to menu to be able to be passed around also 
    if ([controller isKindOfClass:[MenuViewController class]]){
        ((MenuViewController *)controller).localUser = self.localUser;
    }
    
    // Monitor network connection
    APIClient *client = [APIClient sharedClient];
    [client startMonitoringConnection];
    
    // So we can slide menu out
    ECSlidingViewController *slideController = [self slidingViewController];
    if (slideController){
        [self.view addGestureRecognizer:slideController.panGesture];
    }
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
    self.scrollView.delegate = self;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.tag = 1 * 100;
    
    // Scroll view pages based on the height of frame so set it based on screen size
    int offset = 60;
    if (IS_IPHONE_4_OR_LESS){
        offset = 0;
    }
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, SCREEN_HEIGHT - offset);
    
    
    self.pageNumber = 1;
    self.serverLimit = @"10";
    self.serverOffset = @"0";
    self.serverQuery = self.serverQuery? self.serverQuery:@"Featured";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults objectForKey:self.serverQuery];
    self.serverUUID = uuid;
    
    //[self makeTestCards];
    
    
    
    
    [self setup];
    [self setupInterstitialMillenialAd];
    [self setupFBInterstitial];
    [self listenForNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:kAnonymousUser]){
        return;
    }
    
    if (![defaults boolForKey:@"loggedIn"]){
        // set first tip as no so it cab be seen on log in
        [defaults setBool:NO forKey:@"firstTip"];
        [self showLoginScreen];
    }
    else if (![EasyFacebook sharedEasyFacebookClient].isLoggedIn){
        [self showLoginScreen];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (IS_IPHONE_4_OR_LESS){
        //self.scrollView.contentOffset= CGPointMake(0, 0);
    }
    
    
    
    // Launchkit stuff
    if ([self.localUser.logged_in boolValue]){
        [[LaunchKit sharedInstance] setUserIdentifier:self.localUser.facebook_id
                                                email:nil
                                                 name:self.localUser.name];
    }
    
    [[LaunchKit sharedInstance] presentAppReleaseNotesFromViewController:self completion:^(BOOL didPresent) {
        if (didPresent) {
            DLog(@"Woohoo, we showed the release notes card!");
            [self showFirstPopUp];
        }
    }];
    
    
    // create channel for PArse
    [self createParseChannel];
    
    // show quick tip
    [self showFirstPopUp];
    
    if (!self.firstDataFetch){
        [self fetchCardsForScrollView:self.scrollView];
        self.firstDataFetch = YES;
    }
    
    [self fetchUserInfo];
    [self fetchLatestShareText];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self saveCardsToCache];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)listenForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuChoseCategoryOption:) name:kNotificationMenuTappedCategoryChoice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareScreen:) name:kNotificationSubmittedCard object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closedAdNotif:) name:kNotificationClosedADPlacement object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kNotificationLogOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyCardContoller:) name:kNotificationShowCardWithId object:nil];
}

- (void)showFirstPopUp
{
    // show quick tip
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"firstTip"]){
        if ([self.presentedViewController isKindOfClass:[LKViewController class]]){
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowShareImageTip
                                                            object:self
                                                          userInfo:@{@"text":NSLocalizedString(@"Double tap image to share!", nil)}];
        [defaults setBool:YES forKey:@"firstTip"];
        
    }

}

- (void)showLoginScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardLogin];
    ((ViewController *)controller).localUser = self.localUser;
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)setup
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBannerLogo]];
    
    FAKIonIcons *menuIcon = [FAKIonIcons naviconRoundIconWithSize:35];
    UIImage *menuImage = [menuIcon imageWithSize:CGSizeMake(35, 35)];
    FAKIonIcons *addIcon = [FAKIonIcons plusRoundIconWithSize:35];
    UIImage *addImage = [addIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStylePlain target:self action:@selector(showAddCardScreen)];

    

    
}

- (void)createParseChannel
{
    if (self.localUser.name){
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSArray *channels = currentInstallation.channels;
        for (NSString *channel in channels){
            if ([channel isEqualToString:[self.localUser formattedName]]){
                return;
            }
        }
        
        [currentInstallation addUniqueObject:[self.localUser formattedName] forKey:@"channels"];
        [currentInstallation saveInBackground];

    }
}

- (void)fetchUserInfo
{
    [User getMe:^(APIRequestStatus status, id  _Nonnull data) {
        if (status == APIRequestStatusSuccess){
            NSDictionary *userData = data[@"data"][@"user"];
            NSString *username = userData[@"username"];
            NSString *email = userData[@"email"];
            NSNumber *is_staff = userData[@"is_staff"];
            NSString *facebook_id = userData[@"facebook_id"];
            
            self.localUser.name = username;
            self.localUser.email = email;
            self.localUser.is_staff = is_staff;
            self.localUser.facebook_id = facebook_id;
            [self.localUser.managedObjectContext save:nil];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:email forKey:kEmail];
            [defaults setValue:username forKey:kUsername];
            [defaults setValue:facebook_id forKey:kID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserTrackingReady object:nil];
            
        }
    }];
}

- (void)fetchLatestShareText
{
    [User getLatestShareTextWithBlock:^(APIRequestStatus status, id  _Nonnull data) {
        if (status == APIRequestStatusSuccess){
            NSDictionary *serverShareText = data[@"data"][@"share_text"];
            if (serverShareText){
                [self handleServerShareText:serverShareText];
            }
        }
    }];
}


- (void)fetchCardsForScrollView:(UIScrollView *)scrollview
{
    // first remove error view as subview of scrollview
    [self hideErrorView];
    
    // See if we have any cached data for the category name
    self.cardData = [[PINCache sharedCache] objectForKey:self.serverQuery];
    
    // If so go ahead and lay the views out
    if ([self.cardData count] > 0){
        [self setupCardsOnScrollView:scrollview];
    }
    else{
        self.serverUUID = @"000";
    }
    
// Still check if we have any newer data from server
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    NSString *query = self.serverQuery;
    NSString *limit = self.serverLimit;
    NSString *offset = self.serverOffset;
    NSString *uuid = self.serverUUID;
    
    [User showCardsWithParams:@{}
                    GETParams:[NSString stringWithFormat:@"?q=%@&limit=%@&offset=%@&uuid=%@",query,limit,offset,uuid]
                        block:^(APIRequestStatus status, id data,NSInteger status_code) {
                            [self.hud hide:YES];
                            if (status == APIRequestStatusSuccess){
                                
                                if (status_code == 222){
                                    if ([self.scrollView.subviews count] > 0){
                                        return;
                                    }
                                    else{
                                        [self showErrorView];
                                        // assumes that we have a stale uuid so send this to get new data
                                        self.serverUUID = @"000";
                                    }
                                }
                                
                                [self.cardData removeAllObjects];
                                for (NSDictionary *cardDict in data[@"data"][@"cards"]){
                                    Card *card = [Card createCardWithData:cardDict];
                                    [self.cardData addObject:card];
                                    
                                }
                                
                                if ([self.cardData count] > 0){
                                    [[PINCache sharedCache] setObject:self.cardData forKey:self.serverQuery];
                                
                                    // if we have data layout cards and get offsets and limits
                                    // get next limit and offset from data and store it locally
                                    NSNumber *next_limit = data[@"data"][@"next_limit"];
                                    NSNumber *next_offset = data[@"data"][@"next_offset"];
                                    
                                    if (![next_limit intValue] || ![next_offset intValue]){
                                        self.stopServerFetch = YES;
                                    }
                                    else{
                                        self.serverLimit = [NSString stringWithFormat:@"%@",next_limit];
                                        self.serverOffset = [NSString stringWithFormat:@"%@",next_offset];
                                    }
                                    
                                    [self saveUUID:data[@"data"][@"uuid"]];

                                    [self setupCardsOnScrollView:scrollview];
                                }
                                else{
                                    // there were no cards so show error
                                    [self showErrorView];
                                }
                                
                                
                            }
                            else{
                                DLog(@"There was an issue fetching new cards. Please try again.");
                                if ([self.cardData count] == 0){
                                    [self showErrorView];
                                }
                            }
                        }];
}


- (void)saveUUID:(NSString *)uuid
{
    // Save the uuid for this specific catergory (serverQuery)
    if (uuid){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:uuid forKey:self.serverQuery];
        self.serverUUID = uuid;
    }
    
}

- (void)saveCardsToCache
{
     [[PINCache sharedCache] setObject:self.cardData forKey:self.serverQuery];
}

- (void)handleServerShareText:(NSDictionary *)share_text
{
    /*
     share dict will have 'message', 'id', and 'display'
     */
    if (!share_text || [share_text isKindOfClass:[NSNull class]]){
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *oldShareID = [defaults objectForKey:kServerShareTextID];
    NSNumber *currentShareID = share_text[@"id"];
    NSString *message = share_text[@"message"];
    NSString *display = share_text[@"display"];
    // Make sure they are both here
    if (oldShareID && currentShareID){
        // if the old share id isnt equal to this one show the message
        if ([oldShareID longValue] != [currentShareID longValue]){
            [self showServerShareText:message andDisplay:display];
            [defaults setObject:currentShareID forKey:kServerShareTextID];
        }
    }
    else if (!oldShareID){
        // this is first time, show message
        [self showServerShareText:message andDisplay:display];
        [defaults setObject:currentShareID forKey:kServerShareTextID];
        
    }
}
- (void)setupCardsOnScrollView:(UIScrollView *)scrollview
{
    int i = 0;
    NSUInteger count = [self.cardData count];
    self.cardCount = count;
    // add count to info so can later use
    scrollview.myInfo = [NSNumber numberWithInteger:count];
    NSInteger height = scrollview.frame.size.height;
    
    if ([scrollview.subviews count] > 0){
        [scrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (Card *card in self.cardData) {
        HomeContainerView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        containerView.frame = CGRectMake(0,height * i ,self.view.frame.size.width, height);
        containerView.countLabel.text = [NSString stringWithFormat:@"%d/%lu",i + 1,(unsigned long)count];
        containerView.delegate = self;
        // hide bottom a/b/yes/no buttons until image is loaded
        [containerView hideButtons];
        // image should load and buttons shown after setting card
        containerView.card = card;
        [containerView showCachedResults];
        [scrollview addSubview:containerView];
        i++;
    }
    
    scrollview.contentSize = CGSizeMake(self.view.frame.size.width, height * i);
}


- (void)makeTestCards
{
    // Scroll view pages based on the height of frame so set it based on screen size
    int offset = 60;
    if (IS_IPHONE_4_OR_LESS){
        offset = 0;
    }
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, SCREEN_HEIGHT - offset);
    
    int i = 0;
    int count = 10;
    NSInteger height = self.scrollView.frame.size.height;
    self.cardCount = count;
    while (i < count) {
        Card *card = [[Card alloc] init];
        NSArray *options = @[[NSNumber numberWithInt:QuestionTypeAorB],[NSNumber numberWithInt:QuestionTypeYESorNO]];
        id type = options[arc4random_uniform([options count])];
        //card.questionType = [NSString stringWithFormat:@"%@",type];
        
        [self.cardData2 addObject:card];
        HomeContainerView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        containerView.frame = CGRectMake(0,height * i ,self.view.frame.size.width, height);
        containerView.countLabel.text = card.voteCountString;
        containerView.titleLabel.text = card.question;
        if ([card.questionType intValue] == QuestionTypeAorB){
            containerView.imageView.image = [UIImage imageNamed:@"card2"];
            containerView.titleLabel.text = @"Trip to Las Vegas or Miami?";
        }
        else{
            containerView.imageView.image = [UIImage imageNamed:@"card"];
            containerView.titleLabel.text = @"Men's style goals?";
        }
        [containerView.userImageView sd_setImageWithURL:card.senderImgUrl placeholderImage:[UIImage imageNamed:kAppPlaceholer]];
        containerView.countLabel.text = [NSString stringWithFormat:@"%d/%d",i + 1,count];
        containerView.delegate = self;
        containerView.card = card;
        
        [self.scrollView addSubview:containerView];
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height * i);

}

- (void)showErrorView
{
    if (self.errorView.isHidden){
        self.errorView.hidden = NO;
        self.errorView.alpha = 1;
        
        if (!self.errorView.superview){
            [self.scrollView addSubview:self.errorView];
        }
    }
}

- (void)hideErrorView
{
    self.errorView.hidden = YES;
    self.errorView.alpha = 0;
    [self.errorView removeFromSuperview];
}

- (void)setupFBInterstitial
{
    [FBAdSettings addTestDevice:@"7e7c09f866e0f978343a3430b41eb486af529d9f"];
    self.fbinterstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:@"174386719561142_199034547096359"];
    self.fbinterstitialAd.delegate = self;
}

- (void)showFBInterstitial
{
    [self.fbinterstitialAd loadAd];
}


- (void)setupInterstitialMillenialAd
{
    self.interstitialAd = [[MMInterstitialAd alloc] initWithPlacementId:@"215657"];
    self.interstitialAd.delegate = self;
    [self.interstitialAd load:nil];
}

- (void)showInterstitialMillenialAd
{
    if (self.interstitialAd.ready){
        [self.interstitialAd showFromViewController:self];
    }
    else{
        [self showFBInterstitial];
    }
}

- (void)showServerShareText:(NSString *)text andDisplay:(NSString *)display
{
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([display isEqualToString:@"banner"]){
            NSDictionary *options = @{
                                      kCRToastTextKey :text,
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor colorWithHexString:kColorFlatTurquoise],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight),
                                      kCRToastTextColorKey:[UIColor whiteColor],
                                      kCRToastFontKey:[UIFont fontWithName:kFontGlobalBold size:18],
                                      kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar)
                                      };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                        }];
            
        }
        else if ([display isEqualToString:@"alert"]){
            [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Quick Message", nil)
                                                         message:text
                                                      controller:self];
        }
        else if ([display isEqualToString:@"popup"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowShareImageTip
                                                                object:self
                                                              userInfo:@{@"text":text}];
        }

    });
    

    
}

- (void)goToNextPage
{
    if ([self myPageNumber] != self.cardCount){
        UIScrollView *scroll = self.scrollView;
        [UIView animateWithDuration:.3
                              delay:2
                            options:0
                         animations:^{
                             CGFloat pageHeight = scroll.frame.size.height;
                             scroll.contentOffset = CGPointMake(0, pageHeight * self.pageNumber + 1);
                             
                         } completion:nil];
    }
    
    
}


- (NSInteger)myPageNumber
{
    UIScrollView *scroll = self.scrollView;
    CGFloat pageHeight = scroll.frame.size.height;
    float fractionalPage = scroll.contentOffset.y / pageHeight;
    NSInteger page = lround(fractionalPage);
    page = page + 1;
    if (self.pageNumber != page) {
        NSLog(@"%ld",(long)page);
        self.pageNumber = page;
        /* Page did change */
        DLog(@"page changes");
    }
    
    return page;

}

- (void)showMyCardContoller:(NSNotification *)notif
{
    NSDictionary *data = notif.userInfo;
    NSNumber *card_id = data[@"card_id"];
    if (card_id){
        ProfileViewController *profileController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:kStoryboardProfile];
        profileController.card_id = card_id;
        profileController.localUser = self.localUser;
        profileController.screenType = ProfileScreenMe;
        UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:profileController];
        [self presentViewController:base animated:YES completion:nil];
    }
}



- (void)showMenu
{
    ECSlidingViewController *controller = [self slidingViewController];
    if (controller.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered){
        [controller anchorTopViewToRightAnimated:YES];
    }
    else{
        [controller resetTopViewAnimated:YES];
    }
}

- (void)addViewController:(UIViewController *)controller
             toController:(UIViewController *)controller2
                   inView:(UIView *)view
{
    [controller2 addChildViewController:controller];
    [controller didMoveToParentViewController:controller2];
    controller.view.frame = view.bounds;
    [view addSubview:controller.view];
    
}

- (void)menuChoseCategoryOption:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo;
    // Name is used for search term (name of menu selection) and number is used for tags
    // on scrollviews (number of menu selection)
    NSString *name = data[@"name"];
    DLog(@"option was %@",name);
    
    // Hide this view because it sometimes shows at a bad time
    [self hideErrorView];
    
    // save page number for use for later scroll
    NSInteger oldPage = [self myPageNumber];
    NSString *oldName = [NSString stringWithFormat:@"%@-scrollNumber",self.serverQuery];
    [[PINCache sharedCache] setObject:[NSNumber numberWithInteger:oldPage] forKey:oldName];
    
    // save cards to cache before fetching next card data
    [self saveCardsToCache];
    
    // Let controller no search term and offsets and limit for fetch
    self.serverQuery = name;
    self.serverLimit = @"10";
    self.serverOffset = @"0";
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [defaults objectForKey:name];
    self.serverUUID = uuid;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.cardData = [[PINCache sharedCache] objectForKey:self.serverQuery];
    
    [self fetchCardsForScrollView:self.scrollView];
    [self fetchLatestShareText];
    
    // see if there's a cached scroll position for this page name
    NSString *newName = [NSString stringWithFormat:@"%@-scrollNumber",self.serverQuery];
    NSNumber *cachedPageNumber = [[PINCache sharedCache] objectForKey:newName];
    if (cachedPageNumber){
        CGFloat pageHeight = self.scrollView.frame.size.height;
        NSInteger page = [cachedPageNumber integerValue] - 1;
        int offset = pageHeight * page;
        self.scrollView.contentOffset = CGPointMake(0,offset);
    }
    
    
    
}


- (void)showShareScreen:(NSNotification *)notif
{
    NSDictionary *payload = notif.userInfo;
    UIImage *shareImage = payload[@"shareImage"]? payload[@"shareImage"]:nil;
    NSString *shareText = payload[@"shareText"]? payload[@"shareText"]:nil;
    Card *card = payload[@"card"]? payload[@"card"]:nil;
    
    FAKIonIcons *checkIcon = [FAKIonIcons checkmarkIconWithSize:50];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorRed]];
    UIImage *checkImage = [checkIcon imageWithSize:CGSizeMake(50, 50)];
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    if ([controller isKindOfClass:[ShareViewController class]]){
        ((ShareViewController *)controller).card = card;
        ((ShareViewController *)controller).localUser = self.localUser;
        ((ShareViewController *)controller).topImage = checkImage;
        ((ShareViewController *)controller).shareImage = shareImage;
        ((ShareViewController *)controller).imageViewText = shareText;
        ((ShareViewController *)controller).subtitleText = NSLocalizedString(@"We receive ALOT of cards daily, so only the intersting ones will be chosen. Ask friends for a better chance at being featured.", nil);
        ((ShareViewController *)controller).titleText = NSLocalizedString(@"YOUR CARD WAS CREATED!", nil);
        //((ShareViewController *)controller).bottomShareText = NSLocalizedString(@"Ask ", nil)
        
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}
- (void)showAddCardScreen
{
    if (![self.localUser.anonymous boolValue]){
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCreateVote];
        if ([controller isKindOfClass:[CreateVoteController class]]){
            ((CreateVoteController *)controller).localUser = self.localUser;
        }
        UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:base animated:YES completion:nil];
    }
    else{
        PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Anonymous User Alert", nil)
                                                                         message:NSLocalizedString(@"You need to login before creating your own cards.", nil)
                                                                  preferredStyle:PSTAlertControllerStyleAlert];
        
        PSTAlertAction *cancelButton = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel
                                                          handler:^(PSTAlertAction *action) {
                                                              [alert dismissAnimated:YES completion:nil];
                                                          }];
        
        
        
        PSTAlertAction *loginButton = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Login", nil) style:PSTAlertActionStyleDefault
                                                       handler:^(PSTAlertAction *action) {
                                                           // login alert
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogOut object:nil];
                                                           [alert dismissAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancelButton];
        [alert addAction:loginButton];
        [alert showWithSender:self controller:self animated:YES completion:nil];
    }
    
}

- (void)closedAdNotif:(NSNotification *)notif
{
    self.showingAD = NO;
}

- (void)showInternalCustomADPlacement
{

    // This is for ads from internal company partners
    UIViewController *adController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardADPlacement];
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:adController];
    [self presentViewController:base animated:YES completion:^{
        self.showingAD = YES;
    }];
}


#pragma -mark HomeErrorView

- (void)homeErrorViewTappedButton:(HomeErrorView *)view
{
    // View thats shown if no cards come back to display 
    view.hidden = YES;
    view.alpha = 0;
    [self fetchCardsForScrollView:self.scrollView];
}

#pragma -mark HomeContainerView
- (void)homeView:(HomeContainerView *)view tappedButtonNumber:(int)number forType:(QuestionType)type
{
    // number will be button 1 or button 2
    DLog(@"tapped button %d",number);
    [self goToNextPage];
    
    if (self.pageNumber == 4){
        // show one more share tip when user answers
        [self showServerShareText:NSLocalizedString(@"Only 5 shares left. Double tap now.", nil) andDisplay:@"popup"];
    }
    
    [User sendVoteForCard:view.card.id
                     vote:number
                    block:^(APIRequestStatus status, id data) {
                        if (status == APIRequestStatusSuccess){
                            DLog(@"Successfully updated card");
                        }
                        else{
                            DLog(@"Failed to update card");
                        }
                    }];
    
    
}

- (void)homeView:(HomeContainerView *)view tappedShareImage:(UIImage *)img withTitle:(NSString *)title
{
    ShareViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    controller.titleText = NSLocalizedString(@"SHARE THE LOVE!", nil);
    controller.subtitleText = NSLocalizedString(@"Sharing is caring so make sure you show off this awesomeness.", nil);
    controller.shareImage = img;
    controller.imageViewText = title;
    controller.bottomShareText = NSLocalizedString(@"Share with friends on...", nil);
    controller.card = view.card;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)homeViewTappedUserContainer:(HomeContainerView *)view
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardProfile];
    if ([controller isKindOfClass:[ProfileViewController class]]){
        ((ProfileViewController *)controller).card = view.card;
        ((ProfileViewController *)controller).screenType = ProfileScreenOthers;
        UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:base animated:YES completion:nil];
    }
}

- (void)homeView:(HomeContainerView *)view tappedFullScreenImage:(UIImage *)img
{
    FullScreenImageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFullScreen];
    controller.image = img;
    [self presentViewController:controller animated:NO completion:nil];
}

#pragma -mark ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //DLog(@"started scroll");
    //static NSInteger previousPage = 0;
    CGFloat pageHeight = scrollView.frame.size.height;
    float fractionalPage = scrollView.contentOffset.y / pageHeight;
    NSInteger page = lround(fractionalPage);
    page = page + 1;
    if (self.pageNumber != page) {
        NSLog(@"%ld",(long)page);
        self.pageNumber = page;
        /* Page did change */
        DLog(@"page changes");
    }
    
    

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (self.pageNumber == self.cardCount){
        if (!self.showingAD){
            //[self showAdPlacement];
            [self showInterstitialMillenialAd];
        }
    }
    
    if (self.pageNumber == 10){
        [self showServerShareText:NSLocalizedString(@"Sharing is caring. Double tap now!", nil) andDisplay:@"popup"];
    }
}

#pragma -mark FB ads delegate
- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    DLog(@"fb ad failed with error %@",error.description);
}

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    DLog(@"%@ fb ad is ready to be displayed",interstitialAd.description);
    [interstitialAd showAdFromRootViewController:self];
    self.showingAD = YES;
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    DLog(@"The user clicked on the ad and will be taken to its destination");
    // Use this function as indication for a user's click on the ad.
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    DLog(@"The user clicked on the close button, the ad is just about to close");
    // Consider to add code here to resume your app's flow
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    DLog(@"Interstitial had been closed");
    // Consider to add code here to resume your app's flow
    //self.fbinterstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:@"174386719561142_199034547096359"];
    self.showingAD = NO;
}


#pragma -mark Millenial ads delegate
- (void)interstitialAd:(MMInterstitialAd *)ad loadDidFailWithError:(NSError *)error
{
    DLog(@"add 'load' failed with error %@ and code %ld",error.localizedDescription,(long)error.code);
}

- (void)interstitialAd:(MMInterstitialAd *)ad showDidFailWithError:(NSError *)error
{
    DLog(@"add 'show' failed with error %@ and code %ld",error.localizedDescription,(long)error.code);
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd *)ad
{
    self.showingAD = NO;
    MMRequestInfo *info = [[MMRequestInfo alloc] init];
    [self.interstitialAd load:info];
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd *)ad
{
    DLog(@"showing ad %@",ad.description);
    self.showingAD = YES;
    
}

#pragma -mark Email delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark Getters

- (NSMutableArray *)cardData
{
    if (!_cardData){
        _cardData = [NSMutableArray array];
    }
    
    return _cardData;
}

- (NSMutableArray *)cardData2
{
    if (!_cardData2){
        _cardData2 = [NSMutableArray array];
    }
    
    return _cardData2;
}

- (HomeErrorView *)errorView
{
    if (!_errorView){
        _errorView = [[[NSBundle mainBundle] loadNibNamed:@"HomeErrorView" owner:self options:nil] objectAtIndex:0];
        _errorView.frame = CGRectMake(0,0,200,300);
        _errorView.center = CGPointMake(self.view.center.x, 200);
        _errorView.delegate = self;
        [self.scrollView addSubview:_errorView];

    }
    
    return _errorView;
}
@end
