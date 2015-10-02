//
//  HomeViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeFeedCell.h"
#import "CreateVoteController.h"
#import <UIViewController+ECSlidingViewController.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import "UIColor+HexValue.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <CRToast.h>

//#import <CBStoreHouseRefreshControl.h>
#import "constants.h"

@interface HomeViewController()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
//@property (strong,nonatomic) CBStoreHouseRefreshControl *refreshControl;

@end
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // So we can slide menu out
    ECSlidingViewController *slideController = [self slidingViewController];
    [self.view addGestureRecognizer:slideController.panGesture];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    
    [self setup];
    [self listenForNotifications];
    
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
    
    self.view.backgroundColor = [UIColor colorWithHexString:kColorLightGrey];
    

    
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


#pragma -mark ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self.refreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //[self.refreshControl scrollViewDidEndDragging];
}

#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeFeedCell"];
    cell.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [UIColor lightGrayColor];
    cell.selectedBackgroundView = tappedBackgroundColor;
    ((HomeFeedCell *)cell).mainTitleLabel.text = @"Miguel x Cameon carson";
    ((HomeFeedCell *)cell).subTitleLabel.text = @"Cameron Carson";
    ((HomeFeedCell *)cell).timeAgoLabel.text = @"2hr";
    ((HomeFeedCell *)cell).categoryLabel.text = @"Featured";
    ((HomeFeedCell *)cell).mainImageView.image = [UIImage imageNamed:@"bigbody"];
    ((HomeFeedCell *)cell).subImageView.image = [UIImage imageNamed:@"bigsmile"];
    
    
    
    
    return cell;
    
}

#pragma -mark Email delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
