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
    
    [self setup];
 

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
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

- (void)showAddVoteScreen
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCreateVoteRoot];
    [self presentViewController:controller animated:YES completion:nil];
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
    cell.backgroundColor = [UIColor whiteColor];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = tappedBackgroundColor;
    ((HomeFeedCell *)cell).mainTitleLabel.text = @"Miguel x Cameon carson";
    ((HomeFeedCell *)cell).subTitleLabel.text = @"Cameron Carson";
    ((HomeFeedCell *)cell).timeAgoLabel.text = @"2hr";
    ((HomeFeedCell *)cell).categoryLabel.text = @"Featured";
    ((HomeFeedCell *)cell).mainImageView.image = [UIImage imageNamed:@"bigbody"];
    ((HomeFeedCell *)cell).subImageView.image = [UIImage imageNamed:@"bigsmile"];
    
    
    
    
    return cell;
    
}




@end
