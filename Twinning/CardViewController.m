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
#import "UIColor+HexValue.h"
#import "ShareViewController.h"
#import "HomeResultView.h"
#import "FullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <PSTAlertController.h>
#import <CRToast.h>
#import <BranchUniversalObject.h>
#import <BranchLinkProperties.h>

@interface CardViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel;
@property (weak, nonatomic) IBOutlet UILabel *votesLabel2;
@property (strong,nonatomic) NSString *shareLink;
@property (strong, nonatomic) HomeResultView *resultView;
@property (strong, nonatomic) BranchUniversalObject *branchUniversalObject;
@property (strong,nonatomic) BranchLinkProperties *linkProperties;

// Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSParameterAssert(self.card);
    [self setup];
    [self createLink];
    
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
    self.view.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    
    self.titleLabel.text = self.card.question;
    
    NSString *leftName;
    NSString *rightName;
    NSString *voteResultText;
    if ([self.card.questionType intValue] == QuestionTypeAorB){
        leftName = @"A";
        rightName = @"B";
        voteResultText = [NSString stringWithFormat:@"%@%% chose %@ (left) and %@%% chose %@ (right)",self.card.percentVotesLeft,leftName,self.card.percentVotesRight,rightName];
    }
    else if ([self.card.questionType intValue] == QuestionTypeYESorNO){
        leftName = @"YES";
        rightName = @"NO";
        voteResultText = [NSString stringWithFormat:@"%@%% chose %@ and %@%% chose %@",self.card.percentVotesLeft,leftName,self.card.percentVotesRight,rightName];
    }
    
    self.votesLabel.text = [NSString stringWithFormat:@"Out of %@",[self.card voteCountString]];
    self.votesLabel2.text = voteResultText;
    
    FAKIonIcons *personIcon = [FAKIonIcons personIconWithSize:45];
    [personIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    personIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatRed];
    UIImage *personImage = [personIcon imageWithSize:CGSizeMake(50, 50)];
    
    [self.imageView sd_setImageWithURL:self.card.imgUrl placeholderImage:personImage];
    self.imageView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.imageView.userInteractionEnabled = YES;
    
    self.navigationItem.title = NSLocalizedString(([NSString stringWithFormat:@"%@'s Card",self.card.senderName]), nil);
    FAKIonIcons *backIcon = [FAKIonIcons chevronLeftIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:35];
    UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedShare)];

    self.titleLabel.font =  [UIFont fontWithName:kFontGlobalBold size:20];
    self.votesLabel.font =  [UIFont fontWithName:kFontGlobalBold size:15];
    self.votesLabel2.font =  [UIFont fontWithName:kFontGlobalBold size:15];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.votesLabel.textColor = [UIColor whiteColor];
    self.votesLabel.hidden = YES;
    self.votesLabel.alpha = 0;
    self.votesLabel2.textColor = [UIColor whiteColor];
    self.votesLabel2.hidden = YES;
    self.votesLabel2.alpha = 0;
    
    if (IS_IPHONE_4_OR_LESS){
        self.titleLabel.font =  [UIFont fontWithName:kFontGlobalBold size:16];
        self.imageViewHeightConstraint.constant = 250;
    }
    
    self.resultView = [[[NSBundle mainBundle] loadNibNamed:@"HomeResultView" owner:self options:nil] objectAtIndex:0];
    self.resultView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.resultView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    // Must set result view data before setting as subview of image
    if ([self.card.questionType intValue] == QuestionTypeYESorNO){
        self.resultView.leftLabel.text = [NSString stringWithFormat:@"%@%% chose YES",self.card.percentVotesLeft];
        self.resultView.rightLabel.text = [NSString stringWithFormat:@"%@%% chose NO",self.card.percentVotesRight];
    }
    else if ([self.card.questionType intValue] == QuestionTypeAorB){
        self.resultView.leftLabel.text = [NSString stringWithFormat:@"%@%% chose A",self.card.percentVotesLeft];
        self.resultView.rightLabel.text = [NSString stringWithFormat:@"%@%% chose B",self.card.percentVotesRight];
    }
    
    [self.imageView addSubview:self.resultView];
    self.resultView.hidden = YES;
    self.resultView.alpha = 0;
    
    FAKIonIcons *checkIcon = [FAKIonIcons trophyIconWithSize:30];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.resultView.leftImageView.image = [checkIcon imageWithSize:CGSizeMake(45, 45)];
    self.resultView.rightImageView.image = [checkIcon imageWithSize:CGSizeMake(45, 45)];
    
}


- (void)showResults
{
    
    [UIView animateWithDuration:1
                          delay:0
                        options:0
                     animations:^{
                         // show smile icon on the side thats larger
                         if ([self.card.percentVotesLeft longValue] > [self.card.percentVotesRight longValue]){
                             //[self.resultView showLeft];
                         }
                         else{
                             //[self.resultView showRight];
                         }
                         
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1 animations:^{
                             self.votesLabel.hidden = NO;
                             self.votesLabel.alpha = 1;
                             self.votesLabel2.hidden = NO;
                             self.votesLabel2.alpha = 1;
                         }];
                     }];
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
}



- (IBAction)tappedImage:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    if ([view isKindOfClass:[UIImageView class]]){
        FullScreenImageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardFullScreen];
        controller.image = ((UIImageView *)view).image;
        [self presentViewController:controller animated:NO completion:nil];
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

- (void)tappedShare
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        // this crashes on iOS7 so use ios& method
        [self showiOS7ActionSheet];
        return;
    }
    
    PSTAlertController *controller = [PSTAlertController actionSheetWithTitle:NSLocalizedString(@"Share", nil)];
    
    PSTAlertAction *copyLink = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Get Share Link", nil) style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        [self copyShareText];
        
    }];
    
    PSTAlertAction *shareImage = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Share Picture", nil) style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        [self showShare];
        
    }];
    
    PSTAlertAction *cancel = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
        [controller dismissAnimated:YES completion:nil];
    }];
    [controller addAction:copyLink];
    [controller addAction:shareImage];
    [controller addAction:cancel];
    [controller showWithSender:self controller:self animated:YES completion:nil];
}

- (void)showiOS7ActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"Share", nil)
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Get Share Link", nil),NSLocalizedString(@"Share Picture", nil), nil];
    
    [sheet showInView:self.view];
    
}


- (void)showShare
{
    ShareViewController *shareController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    shareController.titleText = NSLocalizedString(@"SPREAD THE LOVE!", nil);
    shareController.subtitleText = self.titleLabel.text;
    shareController.bottomShareText = NSLocalizedString(@"Share With Friends On...", nil);
    shareController.shareImage = self.imageView.image;
    shareController.card = self.card;
    
    [self presentViewController:shareController animated:YES completion:nil];
}

- (void)copyShareText
{
    if (self.shareLink){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.shareLink;
        
        NSDictionary *options = @{
                                  kCRToastTextKey :NSLocalizedString(@"Link copied to clipboard",nil),
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
    }

    
}


#pragma -mark iOS7 action sheet delegat
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0){
        // Tapped copy link
        [self copyShareText];
    }
    else if (buttonIndex == 1){
        // Tapped share picture
        [self showShare];
    }
}


@end
