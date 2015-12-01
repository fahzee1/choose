//
//  ChooseViewController.m
//  Choose
//
//  Created by CJ Ogbuehi on 11/11/15.
//  Copyright © 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ChooseViewController.h"
#import "ShareViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "constants.h"
#import "UIColor+HexValue.h"
#import "HomeContainerView.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import "Card.h"

@interface ChooseViewController ()<HomeContainerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;
@property (strong,nonatomic) HomeContainerView *cardContainerView;
@property (strong, nonatomic) Card *card;
@property (assign)BOOL doneVoting;

@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.doneVoting){
        [self close];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupUI
{
    self.navbar.topItem.title = NSLocalizedString(@"Vote Now!", nil);
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navbar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:35];
    UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(35, 35)];
    self.navbar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(share)];

}

- (void)doneChoosing
{
    self.doneVoting = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self share];
    });
}

- (void)close
{
    [self.cardContainerView reset];
    [self.deepLinkingCompletionDelegate deepLinkingControllerCompleted];
}

- (void)sendVote
{
#warning send vote to server
}

- (void)share
{
    ShareViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    controller.titleText = NSLocalizedString(@"SHARE THE LOVE!", nil);
    controller.subtitleText = NSLocalizedString(@"Sharing is caring so make sure you show off this awesomeness.", nil);
    controller.shareImage = self.cardContainerView.imageView.image;
    controller.imageViewText = self.cardContainerView.titleLabel.text;
    controller.card = self.card;
    controller.bottomShareText = NSLocalizedString(@"Share with friends on...", nil);
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma -mark HomeContainerView
- (void)homeView:(UIView *)view tappedButtonNumber:(int)number forType:(QuestionType)type
{
    // number will be button 1 or button 2
    DLog(@"tapped button %d",number);
    [self doneChoosing];
    [self sendVote];
    
}

- (void)homeView:(UIView *)view tappedShareImage:(UIImage *)img withTitle:(NSString *)title
{
    ShareViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    controller.titleText = NSLocalizedString(@"SHARE THE LOVE!", nil);
    controller.subtitleText = NSLocalizedString(@"Sharing is caring so make sure you show off this awesomeness.", nil);
    controller.shareImage = img;
    controller.imageViewText = title;
    controller.bottomShareText = NSLocalizedString(@"Share with friends on...", nil);
    [self presentViewController:controller animated:YES completion:nil];
}



#pragma -mark Deep link controller

@synthesize deepLinkingCompletionDelegate;
- (void)configureControlWithData:(NSDictionary *)data
{
    Card *card = [[Card alloc] init];
    
    // grab data from url
    NSString *card_id = data[@"card_id"];
    NSString *url = data[@"card_image_url"];
    NSString *title = data[@"card_question"];
    NSString *username = data[@"card_sender"];
    NSString *votes = data[@"card_total_votes"];
    NSString *fbID = data[@"card_sender_fb_id"];
    NSString *questionType = data[@"card_question_type"];
    NSString *percentLeft = data[@"card_percent_left"];
    NSString *percentRight = data[@"card_percent_right"];
    
    // create card
    card.id = [NSNumber numberWithInt:[card_id intValue]];
    card.imgUrl = [NSURL URLWithString:url];
    card.question = title;
    card.senderName = username;
    card.voteCount = [NSNumber numberWithLongLong:[votes longLongValue]];
    card.questionType = [NSNumber numberWithInt:[questionType intValue]];
    card.percentVotesLeft = [NSNumber numberWithInt:[percentLeft intValue]];
    card.percentVotesRight = [NSNumber numberWithInt:[percentRight intValue]];
    card.senderFbID = [NSNumber numberWithLongLong:[fbID longLongValue]];
    
    // give container view card and link self as delegate 
    self.cardContainerView.countLabel.text = @"1/1";
    self.cardContainerView.delegate = self;
    self.cardContainerView.card = card;
    self.card = card;
    
}

- (HomeContainerView *)cardContainerView
{
    if (!_cardContainerView){
        _cardContainerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        _cardContainerView.frame = CGRectMake(0,60,self.view.frame.size.width, self.view.frame.size.height - 60);
        [_cardContainerView hideButtons];
        [self.view addSubview:_cardContainerView];
    }
    
    return _cardContainerView;
}

@end
