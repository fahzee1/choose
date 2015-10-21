//
//  HomeViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeFeedCell.h"
#import "ShareViewController.h"
#import "CreateVoteController.h"
#import <UIViewController+ECSlidingViewController.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "UIColor+HexValue.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <CRToast.h>
#import "HomeContainerView.h"
#import "Card.h"

//#import <CBStoreHouseRefreshControl.h>
#import "constants.h"

@interface HomeViewController()<UIScrollViewDelegate,HomeContainerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *cardData;
@property (assign) NSInteger pageNumber;
@property (assign) CGPoint oldOffset;


@end
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    NSInteger height = self.scrollView.frame.size.height;
    while (i < 30) {
        Card *card = [[Card alloc] init];
        [self.cardData addObject:card];
        HomeContainerView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        containerView.frame = CGRectMake(0,height * i,self.view.frame.size.width, height);
        containerView.countLabel.text = card.voteCountString;
        containerView.titleLabel.text = card.question;
        containerView.imageView.image = [UIImage imageNamed:@"test"];
        [containerView.userImageView sd_setImageWithURL:card.senderImgUrl placeholderImage:[UIImage imageNamed:@"app-icon"]];
        containerView.countLabel.text = [NSString stringWithFormat:@"%d/100",i];
        containerView.delegate = self;
        
        [self.scrollView addSubview:containerView];
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height * i);
    
    
    [self setup];
    [self listenForNotifications];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (IS_IPHONE_4_OR_LESS){
        self.scrollView.contentOffset= CGPointMake(0, 0);
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchPopup) name:kNotificationMenuTappedSearch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuChoseCategoryOption:) name:kNotificationMenuTappedCategoryChoice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareScreen:) name:kNotificationSubmittedCard object:nil];
}

- (void)setup
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBannerLogo]];
    
    FAKIonIcons *menuIcon = [FAKIonIcons naviconRoundIconWithSize:35];
    UIImage *menuImage = [menuIcon imageWithSize:CGSizeMake(35, 35)];
    FAKIonIcons *addIcon = [FAKIonIcons plusRoundIconWithSize:35];
    UIImage *addImage = [addIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStylePlain target:self action:@selector(showAddVoteScreen)];

    

    
}


- (void)goToPage:(int)page
{
    page--;
    [UIView animateWithDuration:2
                     animations:^{
                         CGFloat pageHeight = self.scrollView.frame.size.height;
                         self.scrollView.contentOffset = CGPointMake(0, pageHeight * page);
                         self.pageNumber = page + 1;
                     }];

    
}




/*
-(void)setupRefresh
{
    self.refreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableview
                                                                  target:self
                                                           refreshAction:@selector(fetchData)
                                                                   plist:@"storehouse"];
}

- (void)fetchData
{
    [self.refreshControl finishingLoading];
}
*/

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
- (void)showAddVoteScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCreateVoteRoot];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showSearchPopup
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Shadow;
    alert.customViewColor = [UIColor colorWithHexString:kColorRed];
    NSString *title = NSLocalizedString(@"Search and Vote!", nil);
    NSString *subtitle = NSLocalizedString(@"Enter Vote Code Below" , nil);
    NSString *closeButton = NSLocalizedString(@"Cancel", nil);
    NSString *doneButton = NSLocalizedString(@"Search", nil);
    NSString *placeholder1 = NSLocalizedString(@"Enter Code...", nil);
    
    UITextField *commentField = [alert addTextField:placeholder1];
    
    commentField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    [alert addButton:doneButton actionBlock:^{
        DLog(@"search here");
        [self performSearchWithText:commentField.text];
    }];
    
    [alert showEdit:self title:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];

}

- (void)performSearchWithText:(NSString *)text
{
    NSMutableDictionary *options = [@{kCRToastTextKey:NSLocalizedString(@"Searching...", nil),
                              kCRToastTextColorKey:[UIColor whiteColor],
                              kCRToastFontKey:[UIFont fontWithName:@"Futura-CondensedExtraBold" size:18],
                              kCRToastTextAlignmentKey:@(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey:[UIColor colorWithHexString:kColorFlatGreen],
                              kCRToastAnimationInTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey:@(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey:@(CRToastAnimationDirectionBottom),
                              kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar),
                              kCRToastNotificationPresentationTypeKey:@(CRToastPresentationTypePush),
                              kCRToastTimeIntervalKey:@(DBL_MAX),
                              kCRToastShowActivityIndicatorKey:@(YES)}mutableCopy];
    
    // Only show notification if one isnt showing
    if (![CRToastManager isShowingNotification]){
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        // This is called after I've dimissed the Toast
                                        // if success show in table
                                        // if fail run below
                                        if (!0){
                                            NSTimeInterval time2 = 3.0;
                                            options[kCRToastTextKey] = NSLocalizedString(@"Sorry Nothing Found", nil);
                                            options[kCRToastBackgroundColorKey] = [UIColor whiteColor];
                                            options[kCRToastTextColorKey] = [UIColor redColor];
                                            options[kCRToastShowActivityIndicatorKey] = @(NO);
                                            options[kCRToastTimeIntervalKey] = @(time2);
                                            
                                            [CRToastManager showNotificationWithOptions:options
                                                                        completionBlock:nil];
                                            
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                [CRToastManager dismissNotification:YES];
                                            });
                                        }

                                    }];
    }
    
    // Here actually do the searching
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [CRToastManager dismissNotification:YES];
        });
    
    
}

#pragma -mark HomeContainerView
- (void)homeView:(UIView *)view tappedButtonNumber:(int)number forType:(QuestionType)type
{
    // number will be button 1 or button 2
    DLog(@"tapped button %d",number);
    [self goToPage:self.pageNumber + 1.0];
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
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //DLog(@"started scroll");
    //static NSInteger previousPage = 0;
    CGFloat pageHeight = scrollView.frame.size.height;
    float fractionalPage = scrollView.contentOffset.y / pageHeight;
    NSInteger page = lround(fractionalPage);
    NSLog(@"%ld",(long)page);
    if (self.pageNumber != page) {
        self.pageNumber = page;
        /* Page did change */
        DLog(@"page changes");
    }
    

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
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
