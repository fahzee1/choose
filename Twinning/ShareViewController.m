//
//  ShareViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/24/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ShareViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <ASProgressPopUpView.h>
#import "constants.h"
#import "ShareScreenCell.h"
#import "UIColor+HexValue.h"
#import "SocialIconButton.h"
#import <CRToast.h>
#import <MGInstagram.h>
#import <PSTAlertController.h>
#import <Social/Social.h>

@interface ShareViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *middleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageViewLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomShareLabel;

@property (weak, nonatomic) IBOutlet SocialIconButton *shareButton1;
@property (weak, nonatomic) IBOutlet SocialIconButton *shareButton2;
@property (weak, nonatomic) IBOutlet SocialIconButton *shareButton3;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) MGInstagram *ig;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topImageViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonsTopConstraint;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    if (self.topImage){
        self.topImageView.image = self.topImage;
    }
    else{
        FAKIonIcons *smileIcon = [FAKIonIcons happyIconWithSize:50];
        [smileIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:kColorRed]];
        UIImage *smileImage = [smileIcon imageWithSize:CGSizeMake(50, 50)];
        self.topImageView.image = smileImage;
    }
   
    if (self.titleText){
        self.titleLabel.text = self.titleText;
    }
    
    if (self.subtitleText){
        self.subtitleLabel.text = self.subtitleText;
    }
    
    if (self.shareImage){
        self.middleImageView.image = self.shareImage;
    }
    else{
        self.middleImageView.image = [UIImage imageNamed:kAppIcon];
    }
    
    if (self.bottomShareText){
        self.bottomShareLabel.text = self.bottomShareText;
    }
    else{
        self.bottomShareLabel.text = NSLocalizedString(@"Ask Friends On...", nil);
    }
    
    if (self.imageViewText){
        self.imageViewLabel.text = self.imageViewText;
    }
    else{
        self.imageViewLabel.text = @"";
    }
    
    self.titleLabel.textColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.subtitleLabel.textColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.bottomShareLabel.textColor = [UIColor colorWithHexString:kColorBlackSexy];
     self.imageViewLabel.textColor = [UIColor colorWithHexString:kColorDarkGrey];
    self.imageViewLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    self.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    self.subtitleLabel.font = [UIFont fontWithName:kFontGlobal size:17];
    self.bottomShareLabel.font = [UIFont fontWithName:kFontGlobal size:15];

    
    // IG button
    self.shareButton1.type = SocialButtonInstagram;
    
    // FB button
    self.shareButton2.type = SocialButtonFacebook;
    
    // More button
    self.shareButton3.type = SocialButtonMore;
    
    // Done Button
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor colorWithHexString:kColorDarkGrey];


    if (IS_IPHONE_4_OR_LESS){
        self.topImageViewHeightConstraint.constant = 50;
        self.topImageViewWidthConstraint.constant = 50;
        self.middleImageViewHeightConstraint.constant = 50;
        self.middleImageViewWidthConstraint.constant = 50;
    }
    else if (IS_IPHONE_5){
        self.topImageViewHeightConstraint.constant = 70;
        self.topImageViewWidthConstraint.constant = 70;
        self.middleImageViewHeightConstraint.constant = 70;
        self.middleImageViewWidthConstraint.constant = 70;
    }

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

- (IBAction)tappedShareButton1:(UIButton *)sender {
    // IG
    if (![MGInstagram isAppInstalled]){
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Instagram isn't installed on this device.", nil) controller:self];
        return;
    }
    
    self.ig = [[MGInstagram alloc] init];
    self.ig.photoFileName = kInstagramOnlyPhotoFileName;
    [self.ig postImage:self.middleImageView.image withCaption:self.subtitleText inView:self.view];
}

- (IBAction)tappedShareButton2:(UIButton *)sender {
    [self showFacebookShareScreenWithText:self.subtitleLabel.text];
}

- (IBAction)tappedShareButton3:(UIButton *)sender {
    [self showSMSorEmailScreenWithText:self.subtitleText];
}

- (IBAction)tappedDone:(UIButton *)sender {
    [self goBack];
}

- (void)saveImageToLibrary
{
    UIImageWriteToSavedPhotosAlbum(self.topImageView.image, nil, nil, nil);
    
  
}


- (void)showFacebookShareScreenWithText:(NSString *)text
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an issue trying to share to Facebook.", nil) controller:self];
           return;
    }
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:text];
    [controller addURL:[NSURL URLWithString:@"https://bnc.lt/m/rfPe58ANMn"]];
    [controller addImage:self.middleImageView.image];
    [self presentViewController:controller animated:YES completion:nil];
    
}
- (void)showSMSorEmailScreenWithText:(NSString *)text
{
    NSString *inviteText = text;
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText,self.middleImageView.image] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    
    if (IS_IPAD){
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
            activityVC.popoverPresentationController.sourceView = self.view;
            
        }
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];

}

@end
