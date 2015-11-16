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
#import "HomeResultView.h"

@interface CardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;
@property (strong, nonatomic) HomeResultView *resultView;
// Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showResults];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)setup
{
    self.titleLabel.text = self.titleText;
    self.votesLabel.text = [NSString stringWithFormat:@"%@ votes", self.voteText];
    self.imageView.image = self.image;
    
    self.navigationItem.title = NSLocalizedString(@"User Cards", nil);
    FAKIonIcons *backIcon = [FAKIonIcons chevronLeftIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:35];
    UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(showShare)];

    self.titleLabel.font =  [UIFont fontWithName:kFontGlobalBold size:20];
    self.votesLabel.font =  [UIFont fontWithName:kFontGlobalBold size:15];
    self.votesLabel.hidden = YES;
    self.votesLabel.alpha = 0;
    
    if (IS_IPHONE_4_OR_LESS){
        self.titleLabel.font =  [UIFont fontWithName:kFontGlobalBold size:16];
        self.imageViewHeightConstraint.constant = 250;
    }
    
    self.resultView = [[[NSBundle mainBundle] loadNibNamed:@"HomeResultView" owner:self options:nil] objectAtIndex:0];
    self.resultView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.resultView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.resultView.leftLabel.text = @"65% chose no";
    self.resultView.rightLabel.text = @"35% chose yes";
    [self.imageView addSubview:self.resultView];
    self.resultView.hidden = YES;
    self.resultView.alpha = 0;
    
}


- (void)showResults
{
  

    self.resultView.leftLabel.text = @"65% chose A";
    self.resultView.rightLabel.text = @"35% chose B";
    
    [UIView animateWithDuration:1
                          delay:0
                        options:0
                     animations:^{
                         [self.resultView showLeft];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1 animations:^{
                             self.votesLabel.hidden = NO;
                             self.votesLabel.alpha = 1;
                         }];
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
