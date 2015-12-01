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

@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic)MBProgressHUD *hud;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSParameterAssert(self.localUser);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSDictionary *dict1 = @{@"title":@"Kid Cudi needs to make a comeback?",@"date":@"3 days ago",@"votes":@"2100"};
    NSDictionary *dict2 = @{@"title":@"Kim k or Amber Rose?",@"date":@"4 days ago",@"votes":@"5323"};
    NSDictionary *dict3 = @{@"title":@"Peanut Butter or Jelly?",@"date":@"1 week ago",@"votes":@"39393"};
    NSDictionary *dict4 = @{@"title":@"Kid Cudi needs to make a comeback?",@"date":@"3 days ago",@"votes":@"3393"};
    self.data = @[dict1,dict2,dict3,dict4];
    
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self fetchNewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Profile", nil);
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    
}

- (void)fetchNewData
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Loading...", nil);
    
    [User fetchMyRecentCards:@{}
                       block:^(APIRequestStatus status, id data) {
                           [self.hud hide:YES];
                           if (status == APIRequestStatusSuccess){
                               DLog(@"data");
                           }
                           else{
                               DLog(@"issues fetching data");
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
        ((ProfileHeaderCell *)cell).profileLabel.text = self.localUser.name;
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.localUser.facebook_id];
        NSURL *fbUrl = [NSURL URLWithString:fbString];
        FAKIonIcons *personIcon = [FAKIonIcons personIconWithSize:45];
        [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        personIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatRed];
        UIImage *personImage = [personIcon imageWithSize:CGSizeMake(50, 50)];
        
        [((ProfileHeaderCell *)cell).profileImageView sd_setImageWithURL:fbUrl placeholderImage:personImage options:SDWebImageRefreshCached];
        

    }
    else{
        NSDictionary *obj = [self.data objectAtIndex:indexPath.row - 1];
        ((ProfileListCell *)cell).cardTitle.text = obj[@"title"];
        ((ProfileListCell *)cell).cardDate.text = obj[@"date"];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Should be selectable because row 0 (header) isnt
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row > 0){
        NSInteger row = indexPath.row -1;
        NSDictionary *obj = [self.data objectAtIndex:row];
        
        CardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCard];
        controller.titleText = obj[@"title"];
        controller.voteText = obj[@"votes"];
        controller.image = [UIImage imageNamed:@"card"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
}



@end
