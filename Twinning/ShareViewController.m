//
//  ShareViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/24/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <ASProgressPopUpView.h>
#import "constants.h"
#import "UIColor+HexValue.h"
#import "SocialIconButton.h"
#import <CRToast.h>
#import <MGInstagram.h>
#import <PSTAlertController.h>
#import <Social/Social.h>
#import <BranchUniversalObject.h>
#import <BranchLinkProperties.h>

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
@property (strong,nonatomic) NSString *shareLink;
@property (strong,nonatomic) NSString *shareText;

@property (strong, nonatomic) BranchUniversalObject *branchUniversalObject;
@property (strong,nonatomic) BranchLinkProperties *linkProperties;

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
    [self createLink];
    
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.localUser = [User getLocalUserInContext:context];
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
        self.middleImageView.image = [UIImage imageNamed:kImageCard2];
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
    
    self.shareText = self.card? self.card.question:self.imageViewLabel.text;

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
    NSString *text = [NSString stringWithFormat:@"%@ Vote now on Choose %@",self.shareText,self.shareLink];
    [self.ig postImage:self.middleImageView.image withCaption:text inView:self.view];
}

- (IBAction)tappedShareButton2:(UIButton *)sender {
    NSString *text = [NSString stringWithFormat:@"%@ Vote now on Choose %@",self.shareText,self.shareLink];
    [self showFacebookShareScreenWithText:text];
}

- (IBAction)tappedShareButton3:(UIButton *)sender {
    NSString *text = [NSString stringWithFormat:@"%@ Vote now on Choose %@",self.shareText,self.shareLink];
    [self showSMSorEmailScreenWithText:text];
}

- (IBAction)tappedDone:(UIButton *)sender {
    [self goBack];
}

- (void)saveImageToLibrary
{
    UIImageWriteToSavedPhotosAlbum(self.topImageView.image, nil, nil, nil);
    
  
}

- (void)createLink
{
    
    if (self.card){
        self.branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:[NSString stringWithFormat:@"card/%@",self.card.id]];
        self.branchUniversalObject.title = self.card.question;
        self.branchUniversalObject.contentDescription = NSLocalizedString(@"Vote now on Choose and vote on topics that really matter.", nil);
        self.branchUniversalObject.imageUrl = [self.card.imgUrl absoluteString];
        [self.branchUniversalObject addMetadataKey:@"card_image_url" value:[self.card.imgUrl absoluteString]];
        [self.branchUniversalObject addMetadataKey:@"card_question" value:self.card.question];
        [self.branchUniversalObject addMetadataKey:@"card_question_type" value:[NSString stringWithFormat:@"%@",self.card.questionType]];
        [self.branchUniversalObject addMetadataKey:@"card_id" value:[NSString stringWithFormat:@"%@",self.card.id]];
        [self.branchUniversalObject addMetadataKey:@"card_sender" value:self.card.senderName];
        [self.branchUniversalObject addMetadataKey:@"card_sender_fb_id" value:[NSString stringWithFormat:@"%@",self.card.senderFbID]];
        [self.branchUniversalObject addMetadataKey:@"card_total_votes" value:[self.card voteCountString]];
        [self.branchUniversalObject addMetadataKey:@"card_percent_left" value:[NSString stringWithFormat:@"%@",self.card.percentVotesLeft]];
        [self.branchUniversalObject addMetadataKey:@"card_percent_right" value:[NSString stringWithFormat:@"%@",self.card.percentVotesRight]];
        
        
        
        
        self.linkProperties = [[BranchLinkProperties alloc] init];
        self.linkProperties.feature = @"sharing";
        self.linkProperties.channel = @"vote card";
        
        [self.branchUniversalObject registerView];
        [self.branchUniversalObject listOnSpotlight];
        [self.branchUniversalObject getShortUrlWithLinkProperties:self.linkProperties
                                                 andCallback:^(NSString *url, NSError *error) {
                                                     if (!error){
                                                         self.shareLink = url;
                                                     }
                                                 }];

    }
    else{
        self.branchUniversalObject = [[BranchUniversalObject alloc] initWithTitle:self.shareText];
        self.branchUniversalObject.contentDescription = @"Choose allows you to vote on anything your heart desires! Create interesting topics and watch in amazement as the community votes. Choose covers everything from politics, celebrities, humor, and music. The choice is yours!";
        // choose image hosted on flickr
        self.branchUniversalObject.imageUrl = kFlickrHostedImage;
        [self.branchUniversalObject addMetadataKey:@"property1" value:@"blue"];
        [self.branchUniversalObject addMetadataKey:@"property2" value:@"red"];
        
        self.linkProperties = [[BranchLinkProperties alloc] init];
        self.linkProperties.feature = @"sharing";
        self.linkProperties.channel = @"Choose";
        
        [self.branchUniversalObject registerView];
        [self.branchUniversalObject listOnSpotlight];
        [self.branchUniversalObject getShortUrlWithLinkProperties:self.linkProperties
                                                 andCallback:^(NSString *url, NSError *error) {
                                                     if (!error){
                                                         self.shareLink = url;
                                                     }
                                                 }];

    }
}


- (void)showFacebookShareScreenWithText:(NSString *)text
{
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"There was an issue trying to share to Facebook.", nil) controller:self];
           return;
    }
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:text];
    [controller addURL:[NSURL URLWithString:self.shareLink]];
    [self presentViewController:controller animated:YES completion:nil];
    
}
- (void)showSMSorEmailScreenWithText:(NSString *)text
{
    NSString *inviteText = text;
    UIImage *image;
    NSURL *imageURL;
    if (self.card){
        image = self.middleImageView.image;
        imageURL = self.card.imgUrl;
    }
    else{
        imageURL = [NSURL URLWithString:kFlickrHostedImage];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText,image] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToFacebook];
    
    if (IS_IPAD){
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
            activityVC.popoverPresentationController.sourceView = self.view;
            
        }
    }

    [self presentViewController:activityVC animated:YES completion:nil];
    
    

}

@end
