//
//  HomeViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewController.h"
#import "HomeFeedCell.h"
#import "ShareViewController.h"
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
#import "User+Utils.h"
#import "AppDelegate.h"
#import "constants.h"

@interface HomeViewController()<UIScrollViewDelegate,HomeContainerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *cardData;
@property (assign) NSInteger pageNumber;
@property (assign) NSInteger cardCount;
@property (assign) CGPoint oldOffset;
@property (assign) BOOL showingAD;
@property (strong , nonatomic) AMPopTip *popTip;
@property (strong,nonatomic) User *localUser;

@end
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //get local user and set it
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserInContext:context];
    
    // So we can slide menu out
    ECSlidingViewController *slideController = [self slidingViewController];
    if (slideController){
        [self.view addGestureRecognizer:slideController.panGesture];
    }
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
    self.scrollView.delegate = self;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    
    self.pageNumber = 1;
    
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
        int typeInt = [(NSNumber *)type intValue];
        card.questionType = typeInt;
        
        [self.cardData addObject:card];
        HomeContainerView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        containerView.frame = CGRectMake(0,height * i ,self.view.frame.size.width, height);
        containerView.countLabel.text = card.voteCountString;
        containerView.titleLabel.text = card.question;
        if (card.questionType == QuestionTypeAorB){
            containerView.imageView.image = [UIImage imageNamed:@"card2"];
            containerView.titleLabel.text = @"Trip to Las Vegas or Miami?";
        }
        else{
            containerView.imageView.image = [UIImage imageNamed:@"card"];
            containerView.titleLabel.text = @"Men's style goals?";
        }
        [containerView.userImageView sd_setImageWithURL:card.senderImgUrl placeholderImage:[UIImage imageNamed:@"app-icon"]];
        containerView.countLabel.text = [NSString stringWithFormat:@"%d/%d",i + 1,count];
        containerView.delegate = self;
        containerView.card = card;
        
        [self.scrollView addSubview:containerView];
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height * i);
    
    
    [self setup];
    [self listenForNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"loggedIn"]){
        // set first tip as no so it cab be seen on log in
        [defaults setBool:NO forKey:@"firstTip"];
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardLogin];
        ((ViewController *)controller).localUser = self.localUser;
        [self presentViewController:controller animated:NO completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (IS_IPHONE_4_OR_LESS){
        //self.scrollView.contentOffset= CGPointMake(0, 0);
    }
    
    // show quick tip
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"firstTip"]){
        NSDictionary *options = @{
                                  kCRToastTextKey : @"Double tap the image to share!",
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
                                        [defaults setBool:YES forKey:@"firstTip"];
                                    }];

    }

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuChoseCategoryOption:) name:kNotificationMenuTappedCategoryChoice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareScreen:) name:kNotificationSubmittedCard object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closedAdNotif:) name:kNotificationClosedADPlacement object:nil];
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

- (void)showTip
{
    NSDictionary *options = @{
                              kCRToastTextKey : @"Double tap the image to share!",
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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"firstTip"]){
        
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        [defaults setBool:YES forKey:@"firstTip"];
                                    }];
        
    }
    else if (![defaults boolForKey:@"secondTip"]){
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        [defaults setBool:YES forKey:@"secondTip"];
                                    }];
        
    }

    else if (![defaults boolForKey:@"thirdTip"]){
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        [defaults setBool:YES forKey:@"thirdTip"];
                                    }];

    }

}

- (void)goToNextPage
{
    if (self.pageNumber == self.cardCount){
        [self showAdPlacement];
        return;
    }
    
    [UIView animateWithDuration:.3
                          delay:2
                        options:0
                     animations:^{
                         CGFloat pageHeight = self.scrollView.frame.size.height;
                         self.scrollView.contentOffset = CGPointMake(0, pageHeight * self.pageNumber + 1);
                         
                     } completion:nil];
    
    
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

- (void)menuChoseCategoryOption:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo;
    NSString *category = data[@"category"];
    DLog(@"option was %@",category);
    
    // with category now fetch data from server here
    
    
}

- (void)showShareScreen:(NSNotification *)notif
{
    NSDictionary *payload = notif.userInfo;
    UIImage *shareImage = payload[@"shareImage"]? payload[@"shareImage"]:nil;
    NSString *shareText = payload[@"shareText"]? payload[@"shareText"]:nil;
    FAKIonIcons *checkIcon = [FAKIonIcons checkmarkIconWithSize:50];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorRed]];
    UIImage *checkImage = [checkIcon imageWithSize:CGSizeMake(50, 50)];
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    if ([controller isKindOfClass:[ShareViewController class]]){
        ((ShareViewController *)controller).topImage = checkImage;
        ((ShareViewController *)controller).shareImage = shareImage;
        ((ShareViewController *)controller).imageViewText = shareText;
        ((ShareViewController *)controller).subtitleText = NSLocalizedString(@"We receive thousands of cards daily and choose the best. Poll friends for a better chance at being featured. Good Luck!", nil);
        ((ShareViewController *)controller).titleText = NSLocalizedString(@"YOUR CARD WAS CREATED!", nil);
        //((ShareViewController *)controller).bottomShareText = NSLocalizedString(@"Ask ", nil)
        
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}
- (void)showAddCardScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCreateVote];
    if ([controller isKindOfClass:[CreateVoteController class]]){
        ((CreateVoteController *)controller).localUser = self.localUser;
    }
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:base animated:YES completion:nil];
}

- (void)closedAdNotif:(NSNotification *)notif
{
    self.showingAD = NO;
}

- (void)showAdPlacement
{

    //then when done turn off showing ad
    UIViewController *adController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardADPlacement];
    UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:adController];
    [self presentViewController:base animated:YES completion:^{
        self.showingAD = YES;
    }];
}



#pragma -mark HomeContainerView
- (void)homeView:(UIView *)view tappedButtonNumber:(int)number forType:(QuestionType)type
{
    // number will be button 1 or button 2
    DLog(@"tapped button %d",number);
    [self goToNextPage];
    
    if (self.pageNumber == 4){
        // show one more share tip when user answers
        [self showTip];
    }
}

- (void)homeView:(UIView *)view tappedShareImage:(UIImage *)img withTitle:(NSString *)title
{
    ShareViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    controller.titleText = NSLocalizedString(@"SHARE THE LOVE!", nil);
    controller.subtitleText = NSLocalizedString(@"Sharing is caring so make sure you show off this awesomeness.", nil);
    controller.shareImage = img;
    controller.imageViewText = title;
    controller.bottomShareText = NSLocalizedString(@"Share with friends on...", nil);
    [self presentViewController:controller animated:YES completion:nil];
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
            [self showAdPlacement];
        }
    }
    
    if (self.pageNumber == 10){
        [self showTip];
    }
}


#pragma -mark Email delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark Getters

- (NSMutableArray *)cardData
{
    if (_cardData){
        _cardData = [NSMutableArray array];
    }
    
    return _cardData;
}
@end
