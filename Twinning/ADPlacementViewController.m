//
//  ADPlacementViewController.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/5/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ADPlacementViewController.h"
#import "constants.h"
#import "UIColor+HexValue.h"

@interface ADPlacementViewController ()
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation ADPlacementViewController

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
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kBannerLogo]];
    self.adTitle.font = [UIFont fontWithName:kFontGlobal size:18];
    self.adTitle.textColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.sponsoredLabel.font = [UIFont fontWithName:kFontGlobal size:14];
    self.sponsoredLabel.textColor = [UIColor colorWithHexString:kColorDarkGrey];
    self.sponsoredLabel.text = NSLocalizedString(@"Sponsored", nil);
    [self.doneButton setBackgroundColor:[UIColor colorWithHexString:kColorRed]];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"CONTINUE", nil) forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    
    self.adImage.userInteractionEnabled = YES;
    self.adTitle.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUrl)];
    tapTitle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUrl)];
    tapImage.numberOfTapsRequired = 1;
    
    [self.adImage addGestureRecognizer:tapImage];
    [self.adTitle addGestureRecognizer:tapTitle];
}

- (void)showUrl
{
    DLog(@"go to google.com");
}

- (IBAction)tappedDoneButton:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationClosedADPlacement object:self];
    
    [self goBack];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
