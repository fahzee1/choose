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
#import "UIColor+HexValue.h"
#import <UIViewController+ECSlidingViewController.h>
#import "constants.h"
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <MessageUI/MessageUI.h>

@interface MenuViewController()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *searchButton;


@end
@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // use this to not allow extra table cells
    
    [self setup];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
}


- (void)setup
{
    self.view.backgroundColor = [UIColor colorWithHexString:kColorRed];
    self.tableview.backgroundColor = [UIColor colorWithHexString:kColorRed];
    
    self.searchButton.backgroundColor = [UIColor whiteColor];
    [self.searchButton setTitleColor:[UIColor colorWithHexString:kColorRed] forState:UIControlStateNormal];
    self.searchButton.titleLabel.text = NSLocalizedString(@"Find Vote Via Code", nil);
    self.searchButton.layer.cornerRadius = 5.f;
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



#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return NSLocalizedString(@"Categories", nil);
    }
    else if (section == 1){
         return NSLocalizedString(@"Account", nil);
    }
    else if (section == 2){
        return NSLocalizedString(@"Support", nil);
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
    myLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor colorWithHexString:kColorLightGrey];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:kColorRed];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        // categories
        return 6;
    }
    else if (section == 1){
        // account
        return 2;
    }
    else if (section == 2){
        // support
        return 2;
    }
    else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = @"";
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
            {
                cellText = NSLocalizedString(@"Featured", nil);
            }
                break;
            case 1:
            {
                cellText = NSLocalizedString(@"Actors", nil);
            }
                break;
            case 2:
            {
                cellText = NSLocalizedString(@"Actresses", nil);
            }
                break;
            case 3:
            {
                cellText = NSLocalizedString(@"Athletes", nil);
            }
                break;
            case 4:
            {
                cellText = NSLocalizedString(@"Models", nil);
            }
                break;
            case 5:
            {
                cellText = NSLocalizedString(@"Personality Stars", nil);
            }
                break;
            case 6:
            {
                cellText = NSLocalizedString(@"Politicians", nil);
            }
                break;
            default:
            {
                cellText = @"Same";
            }
                break;
        }
    }
    
    else if (indexPath.section == 1){
        // Account
        switch (indexPath.row) {
            case 0:
            {
                cellText = NSLocalizedString(@"Recent", nil);
            }
                break;
            case 1:
            {
                cellText = NSLocalizedString(@"Points", nil);
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
        // Support
        switch (indexPath.row) {
            case 0:
            {
                cellText = NSLocalizedString(@"Help", nil);
            }
                break;
            case 1:
            {
                cellText = NSLocalizedString(@"Feedback", nil);
            }
                break;
            case 2:
            {
                cellText = NSLocalizedString(@"Log Out", nil);
            }
                break;
            default:
            {
                cellText = @"Set default";
            }
                break;
        }
        
    }

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    cell.backgroundColor = [UIColor colorWithHexString:kColorFlatRed];
    UIView *tappedBackgroundColor = [UIView new];
    tappedBackgroundColor.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = tappedBackgroundColor;
    ((MenuCell *)cell).name.textColor = [UIColor colorWithHexString:kColorLightGrey];
    ((MenuCell *)cell).name.text = cellText;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ECSlidingViewController *controller = [self slidingViewController];
    
    if (indexPath.section == 0){
        // Category section - when someone taps, close menu and send notification to home screen
        // with name of category (cell)
        if ([cell isKindOfClass:[MenuCell class]]){
            
            [controller resetTopViewAnimated:YES onComplete:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuTappedCategoryChoice
                                                                    object:self
                                                                  userInfo:@{@"category":((MenuCell *)cell).name.text}];
            }];

        }
    }
    
    else if (indexPath.section == 1){
        // Account
        
    }
    
    else if (indexPath.section == 2){
        // Support
        switch (indexPath.row) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                // Feedback
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [controller resetTopViewAnimated:YES
                                      onComplete:^{
                                          if ([MFMailComposeViewController canSendMail]){
                                              MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                                              [mail setSubject:NSLocalizedString(@"Twinning Feedback", nil)];
                                              [mail setToRecipients:@[kTwinningEmail]];
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
}

@end
