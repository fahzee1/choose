//
//  MenuViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/16/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "HomeViewController.h"
#import "ShareViewController.h"
#import "EasyFacebook.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "CreateVoteController.h"
#import "UIColor+HexValue.h"
#import <UIViewController+ECSlidingViewController.h>
#import "constants.h"
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <MessageUI/MessageUI.h>
#import <PSTAlertController.h>
#import <CRToast.h>
#import <Parse/Parse.h>


@interface MenuViewController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *menuTitles;
@property (assign) BOOL setInitialSelection;
@property (assign) BOOL addedFacebookButton;

@end
@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // use this to not allow extra table cells
    [self.tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self setup];


    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchCardLists];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
}


- (void)setup
{
    self.view.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.tableview.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    
    self.searchButton.backgroundColor = [UIColor whiteColor];
    [self.searchButton setTitleColor:[UIColor colorWithHexString:kColorBlackSexy] forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLocalizedString(@"Search Access Codes", nil) forState:UIControlStateNormal];
    self.searchButton.titleLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    self.searchButton.layer.cornerRadius = 5.f;
    
    self.searchBar.hidden = YES;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.barStyle = UIBarStyleBlackTranslucent;
    
}

- (void)fetchCardLists
{
    [User getCardListsForMenu:^(APIRequestStatus status, id  _Nonnull data) {
        if (status == APIRequestStatusSuccess){
            [self.menuTitles removeAllObjects];
            for (NSDictionary *dict in data[@"data"][@"lists"]){
                NSString *name = dict[@"name"];
                [self.menuTitles addObject:name];
            }
            
            NSIndexPath *ipath = [self.tableview indexPathForSelectedRow];
            [self.tableview reloadData];
            [self.tableview selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else{
            
        }
    }];
}

- (void)showNotificationAlert
{
    PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Send Notification", nil)
                                                                     message:NSLocalizedString(@"You're allowed to do this because you are staff. Enter the message to send as notification to all users of this app.", nil)
                                                              preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *cancel = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel
                                                     handler:^(PSTAlertAction *action) {
                                                         [alert dismissAnimated:YES completion:nil];
                                                         
                                                     }];
    
    
    
    PSTAlertAction *done = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:PSTAlertActionStyleDefault
                                                   handler:^(PSTAlertAction *action) {
                                                       if (alert.textField.text){
                                                           PFPush *push = [[PFPush alloc] init];
                                                           [push setChannel:@"Choose"];
                                                           [push setMessage:alert.textField.text];
                                                           [push sendPushInBackground];
                                                       }
                                                       
                                                       [alert dismissAnimated:YES completion:nil];
                                                       // let user know
                                                       NSDictionary *options = @{
                                                                                 kCRToastTextKey :@"Sent notification",
                                                                                 kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                                                                 kCRToastBackgroundColorKey : [UIColor colorWithHexString:kColorFlatTurquoise],
                                                                                 kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                                                                 kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                                                                 kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                                                                 kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                                                                 kCRToastTextColorKey:[UIColor whiteColor],
                                                                                 kCRToastFontKey:[UIFont fontWithName:kFontGlobalBold size:15],
                                                                                 kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar)
                                                                                 };
                                                       [CRToastManager showNotificationWithOptions:options
                                                                                   completionBlock:^{
                                                                                   }];
                                                       
                                                       
                                                   }];
    [alert addAction:cancel];
    [alert addAction:done];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter message", nil);
    }];
    
    [alert showWithSender:self controller:self animated:YES completion:nil];
}

- (IBAction)tappedSearchButton:(UIButton *)sender {
    if (self.delegate){
        [self.delegate menuViewControllerTappedSearch:self];
    }
    
    //UIViewController *controller2 = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardMenu];
    
    
    ECSlidingViewController *controller = [self slidingViewController];
    
    [controller resetTopViewAnimated:YES onComplete:^{
        /*
        if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
            [((UINavigationController *)controller.topViewController) pushViewController:controller2 animated:YES];
        }
         */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuTappedSearch object:nil];
    }];
}
- (void)openAppStoreReview
{
    NSString *appID = kLocalAppID;
    NSString *str;
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (ver >= 7.0 && ver < 7.1) {
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appID];
    } else if (ver >= 8.0) {
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appID];
    } else {
        str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appID];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)openInstagramProfile
{
    
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@",kInstagramUserName]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else{
        instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://instagram.com/%@",kInstagramUserName]];
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

- (void)openFacebookPage
{
    NSURL *fbURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@",kFacebookPageID]];
    if ([[UIApplication sharedApplication] canOpenURL:fbURL]) {
        [[UIApplication sharedApplication] openURL:fbURL];
    }
    else{
        fbURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/%@",kFacebookPageName]];
        [[UIApplication sharedApplication] openURL:fbURL];
    }

}

- (void)showSearchScreenWithText:(NSString *)text;
{
    ECSlidingViewController *controller = [self slidingViewController];
    [controller resetTopViewAnimated:YES
                          onComplete:^{
                              
                              SearchViewController *searchController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardSearch];
                              searchController.searchString = text;
                              if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
                                  UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:searchController];
                                  [((UINavigationController *)controller.topViewController).topViewController presentViewController:base animated:YES completion:nil];
                              }
                          }];
}
#pragma -mark Searchbar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    DLog(@"text is %@",searchText);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    DLog(@"tapped search with text %@",searchBar.text);
    
    [self showSearchScreenWithText:searchBar.text];


}


#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return NSLocalizedString(@"Category", nil);
    }
    else if (section == 1){
         return NSLocalizedString(@"Account", nil);
    }
    else if (section == 2){
        return NSLocalizedString(@"Social", nil);
    }
    else{
        return @"Set title";
    }
}
/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor darkGrayColor];
}
*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, -5, 320, 30);
    myLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        // categories
        
        // see if we have any from server if not use default
        if ([self.menuTitles count] > 0){
            return [self.menuTitles count];
        }
        else{
            return 2;
        }
    }
    else if (section == 1){
        // account
        return 3;
    }
    else if (section == 2){
        // social
        if ([self.localUser.is_staff boolValue]){
            return 5;
        }
        else{
            return 3;
        }
    }
    else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    cell.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    cell.contentView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    
    if (indexPath.section == 0){
        
        if ([self.menuTitles count] > 0){
            cellText = [self.menuTitles objectAtIndex:indexPath.row];
        }
        else{
            switch (indexPath.row) {
                case 0:
                {
                    cellText = NSLocalizedString(@"Featured", nil);
                }
                    break;
                case 1:
                {
                    cellText = NSLocalizedString(@"Daily 12", nil);
                }
                    break;
                case 2:
                {
                    cellText = NSLocalizedString(@"Community", nil);
                }
                    break;
                default:
                {
                    cellText = @"Same";
                }
                    break;
            }
        }
    }
    
    else if (indexPath.section == 1){
        // Account
        switch (indexPath.row) {
            case 0:
            {
                cellText = NSLocalizedString(@"My Questions", nil);
            }
                break;
            case 1:
            {
                cellText = NSLocalizedString(@"Invite Friends", nil);
            }
                break;
            case 2:
            {
                cellText = NSLocalizedString(@"Send Feedback", nil);
            }
                break;
            default:
            {
                cellText = @"Set default";
            }
                break;
        }

    }
    
    
    else if (indexPath.section == 2){
        // Social
        switch (indexPath.row) {
            case 0:
            {
                cellText = NSLocalizedString(@"Like Us On Facebook", nil);
            }
                break;
            case 1:
            {
                cellText = NSLocalizedString(@"Follow Us On Instagram", nil);
            }
                break;
            case 2:
            {
                cellText = NSLocalizedString(@"Give Us A Review", nil);
            }
                break;
            case 3:
            {
                // This cell only shows for staff users
                cellText = NSLocalizedString(@"CREATE AS CHOOSE STAFF", nil);
                cell.backgroundColor = [UIColor colorWithHexString:kColorFlatOrange];
                cell.contentView.backgroundColor = [UIColor colorWithHexString:kColorFlatOrange];
            }
                break;
            case 4:
            {
                // This cell only shows for staff users
                cellText = NSLocalizedString(@"SEND NOTIFICATION", nil);
                cell.backgroundColor = [UIColor colorWithHexString:kColorFlatPurple];
                cell.contentView.backgroundColor = [UIColor colorWithHexString:kColorFlatPurple];
            }
                break;
            default:
            {
                cellText = @"Set default";
            }
                break;
        }
        
    }

    
    ((MenuCell *)cell).name.text = cellText;
    

    /*
    if ([cellText isEqualToString:@"Like Us On Facebook"]){
        [self addFacebookLikeButtonToCell:cell];
    }
    */
    
    return cell;
    
}

- (void)addFacebookLikeButtonToCell:(UITableViewCell *)cell
{
    FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    likeButton.objectID = @"https://www.facebook.com/trychoose/";
    likeButton.center = cell.contentView.center;
    likeButton.frame = CGRectMake(33, likeButton.frame.origin.y, 300, likeButton.frame.size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!self.addedFacebookButton){
        ((MenuCell *)cell).name.hidden = YES;
        [cell.contentView addSubview:likeButton];
        self.addedFacebookButton = YES;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ECSlidingViewController *controller = [self slidingViewController];
    
    if (indexPath.section == 0){
        // deselect initial 
        if (!self.setInitialSelection){
            [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
            self.setInitialSelection = YES;
        }
        
        // Category section - when someone taps, close menu and send notification to home screen
        // with name of category (cell)
        if ([cell isKindOfClass:[MenuCell class]]){
            
            [controller resetTopViewAnimated:YES onComplete:^{
                NSString *name = ((MenuCell *)cell).name.text;
                NSNumber *number = [NSNumber numberWithInteger:indexPath.row + 1];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuTappedCategoryChoice
                                                                    object:self
                                                                  userInfo:@{@"name":name,
                                                                             @"number":number}];
            }];

        }
    }
    
    else if (indexPath.section == 1){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Account
        switch (indexPath.row) {
            case 0:
            {
                // My Questions
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          
                                          UIViewController *profileController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardProfile];
                                          if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
                                              ((ProfileViewController *)profileController).localUser = self.localUser;
                                              ((ProfileViewController *)profileController).screenType = ProfileScreenMe;
                                              UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:profileController];
                                              [((UINavigationController *)controller.topViewController).topViewController presentViewController:base animated:YES completion:nil];
                                          }

                                      }];
                
            }
                break;
            case 1:
            {
                // Share with a friend
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          [[EasyFacebook sharedEasyFacebookClient] inviteFriendsFromController:controller.topViewController];
                                      }];
                
                /*
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                       
                            
                                          ShareViewController *shareController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
                                          shareController.localUser = self.localUser;
                                          shareController.titleText = NSLocalizedString(@"SPREAD THE LOVE!", nil);
                                          shareController.subtitleText = NSLocalizedString(@"Get featured by inviting some friends to Choose!", nil);
                                          shareController.bottomShareText = NSLocalizedString(@"Share With Friends On...", nil);
                                          shareController.imageViewText = NSLocalizedString(@"Vote on the most important topics", nil);
                                          if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
                                              [((UINavigationController *)controller.topViewController).topViewController presentViewController:shareController animated:YES completion:nil];
                                          }
                                      }];
                 */
                
            }
                break;
            case 2:
            {
                // Feedback
                // Feedback
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          if ([MFMailComposeViewController canSendMail]){
                                              MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                                              [mail setSubject:NSLocalizedString(@"Twinning Feedback", nil)];
                                              [mail setToRecipients:@[kChooseEmail]];
                                              if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
                                                  mail.mailComposeDelegate = (HomeViewController *)((UINavigationController *)controller.topViewController).topViewController;
                                              }
                                              else{
                                                  return;
                                              }
                                              
                                              [controller.topViewController presentViewController:mail animated:YES completion:nil];
                                          }
                                      }];

            }
                break;
            default:
                break;
        }
        
    }
    
    else if (indexPath.section == 2){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // Social
        switch (indexPath.row) {
            case 0:
            {
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          [self openFacebookPage];
                                      }];
            }
                break;
            case 1:
            {
                // Like on IG
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          [self openInstagramProfile];
                                      }];
            }
                break;
            case 2:
            {
                // App store review
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          [self openAppStoreReview];
                                      }];
            }
                break;
            case 3:
            {
                // Only staff memebers will see this
                
                UIViewController *createController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCreateVote];
                if ([createController isKindOfClass:[CreateVoteController class]]){
                    ((CreateVoteController *)createController).localUser = self.localUser;
                    ((CreateVoteController *)createController).createCardAs = CreateCardAsStaff;
                }
                
                UINavigationController *base = [[UINavigationController alloc] initWithRootViewController:createController];
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          [controller.topViewController presentViewController:base animated:YES completion:nil];
                                      }];


            }
                break;
            case 4:{
                [self showNotificationAlert];
            }
                break;
            default:
                break;
        }
    }
}

#pragma -mark menu titles

- (NSMutableArray *)menuTitles
{
    if (!_menuTitles){
        _menuTitles = [@[] mutableCopy];
    }
    
    return _menuTitles;
}

/*
 NSString *inviteText = [NSString stringWithFormat:@"Go vote for me on Twinning"];
 UIImage *appImage = [UIImage imageNamed:kAppIcon];
 UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[appImage,inviteText] applicationActivities:nil];
 activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
 
 if (IS_IPAD){
 if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
 activityVC.popoverPresentationController.sourceView = self.view;
 
 }
 }
 
 if ([controller.topViewController isKindOfClass:[UINavigationController class]]){
 [((UINavigationController *)controller.topViewController).topViewController presentViewController:activityVC animated:YES completion:nil];
 }
*/

@end
