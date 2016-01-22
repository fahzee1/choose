//
//  ProfileViewController.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileHeaderCell.h"
#import "ProfileListCell.h"
#import "constants.h"
#import "UIColor+HexValue.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "CardViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <DateTools.h>
#import <PSTAlertController.h>
@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *data;
@property (strong,nonatomic)MBProgressHUD *hud;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (assign) UserStatus userStatus;
@property (assign)BOOL fetchedCards;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.screenType == ProfileScreenMe){
        if ([self.localUser.anonymous boolValue]){
            [self showAnonMessage];
            [self.tableView reloadData];
            return;
        }
    }
    
    if (!self.fetchedCards){
        [self fetchNewData];
        self.fetchedCards = YES;
    }
    
    if (self.card_id){
        [self showCardController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Recent", nil);
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchNewData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
}

- (void)showAnonMessage
{
    PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Anonymous User Alert", nil)
                                                                     message:NSLocalizedString(@"Login to get started using Choose!", nil)
                                                              preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *cancelButton = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel
                                                           handler:^(PSTAlertAction *action) {
                                                               [alert dismissAnimated:YES completion:nil];
                                                           }];
    
    
    
    PSTAlertAction *loginButton = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Login", nil) style:PSTAlertActionStyleDefault
                                                          handler:^(PSTAlertAction *action) {
                                                              // login alert
                                                              [alert dismissAnimated:YES completion:nil];
                                                              [self dismissViewControllerAnimated:NO completion:^{
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogOut object:nil];
                                                              }];
                                                          }];
    [alert addAction:cancelButton];
    [alert addAction:loginButton];
    [alert showWithSender:self controller:self animated:YES completion:nil];
}


- (void)fetchNewData
{

    NSString *fbID = nil;
    if (self.card){
        fbID = self.card.senderFbID;
    }
    else{
        fbID = self.localUser.facebook_id;
    }
    
    
    [User fetchUserCardsWithFBID:fbID
                       GETParams:nil
                           block:^(APIRequestStatus status, id data) {
                               [self.refreshControl endRefreshing];
                               if (status == APIRequestStatusSuccess){
                                   self.data = nil;
                                   for (NSDictionary *cardDict in data[@"data"][@"cards"]){
                                       Card *card = [Card createCardWithData:cardDict];
                                        [self.data addObject:card];
                                   }
                                   
                                   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                               }
                               else{
                                   DLog(@"Failed to get users card");
                                   [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Oops", nil)
                                                                                message:NSLocalizedString(@"There was an error fetching cards.", nil)
                                                                             controller:self];
                                   
                               }
                           }];
}

- (void)showCardController
{
    
    [User getCardWithID:self.card_id
                  block:^(APIRequestStatus status, id  _Nonnull data) {
                      if (status == APIRequestStatusSuccess){
                          Card *card = [Card createCardWithData:data[@"data"][@"card"]];
                          CardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCard];
                          controller.card = card;
                          self.card_id = nil; // need to remove so screen doesnt automatically go to this card
                          [self.navigationController pushViewController:controller animated:YES];
                      }
                  }];
}


- (void)goBack
{
    if ([self.navigationController.viewControllers count] > 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        // Header row
        return 60;
    }
    else{
        // List row
        return 130;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0){
        // header cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"profileHeaderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else{
        // list cells
        cell = [tableView dequeueReusableCellWithIdentifier:@"profileListCell"];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.row == 0){
        // header cell
        
        NSURL *fbURL;
        NSString *senderText;
        if (self.card){
            fbURL = [self.card facebookImageUrl];
            senderText = self.card.senderName;
        }
        else if ([self.localUser.anonymous boolValue]){
            senderText = NSLocalizedString(kAnonymousUser, nil);
        }
        
        else{
            fbURL = [self.localUser facebookImageUrl];
            senderText = self.localUser.name;
        }
        
        ((ProfileHeaderCell *)cell).profileLabel.text = senderText;
        
        // Create person icon as default image
        FAKIonIcons *personIcon = [FAKIonIcons personIconWithSize:45];
        [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        personIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatRed];
        UIImage *personImage = [personIcon imageWithSize:CGSizeMake(50, 50)];
        
        // Load FB image
        [((ProfileHeaderCell *)cell).profileImageView sd_setImageWithURL:fbURL placeholderImage:personImage options:SDWebImageRefreshCached];

    }
    else{
        Card *card = [self.data objectAtIndex:indexPath.row -1];
        ((ProfileListCell *)cell).cardTitle.text = card.question;
        NSString *dateText = card.created.timeAgoSinceNow;
        ((ProfileListCell *)cell).cardDate.text = dateText;
        [((ProfileListCell *)cell).cardImageView sd_setImageWithURL:card.imgUrl placeholderImage:[UIImage imageNamed:kAppPlaceholer]];
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Should be selectable because row 0 (header) isnt
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row > 0){
        NSInteger row = indexPath.row -1;
        Card *card = [self.data objectAtIndex:row];
        
        CardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCard];
        controller.card = card;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
}

#pragma -mark getters

- (NSMutableArray *)data
{
    if (!_data){
        _data = [@[] mutableCopy];
    }
    
    return _data;
}



@end
