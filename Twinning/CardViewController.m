//
//  CardViewController.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/4/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "CardViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "constants.h"
#import "ShareViewController.h"

@interface CardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;


@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"User Cards", nil);
    FAKIonIcons *backIcon = [FAKIonIcons chevronLeftIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:35];
    UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(showShare)];
    
    self.titleLabel.text = self.titleText;
    self.votesLabel.text = [NSString stringWithFormat:@"%@ votes", self.voteText];
    
    self.titleLabel.font =  [UIFont fontWithName:kFontGlobalBold size:20];
    self.votesLabel.font =  [UIFont fontWithName:kFontGlobalBold size:15];
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

- (void)showShare
{
    ShareViewController *shareController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    shareController.titleText = NSLocalizedString(@"SPREAD THE LOVE!", nil);
    shareController.subtitleText = self.titleLabel.text;
    shareController.bottomShareText = NSLocalizedString(@"Share With Friends On...", nil);
    shareController.shareImage = self.imageView.image;
    
    [self presentViewController:shareController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
