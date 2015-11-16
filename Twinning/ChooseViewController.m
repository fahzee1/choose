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

@end

@implementation ChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
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
    self.navbar.topItem.title = NSLocalizedString(@"User Cards", nil);
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navbar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:35];
    UIImage *shareImage = [shareIcon imageWithSize:CGSizeMake(35, 35)];
    self.navbar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(share)];

}

- (void)doneChoosing
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self share];
    });
}

- (void)close
{
    [self.cardContainerView reset];
    [self.deepLinkingCompletionDelegate deepLinkingControllerCompleted];
}

- (void)share
{
    ShareViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    controller.titleText = NSLocalizedString(@"SHARE THE LOVE!", nil);
    controller.subtitleText = NSLocalizedString(@"Sharing is caring so make sure you show off this awesomeness.", nil);
    controller.shareImage = self.cardContainerView.imageView.image;
    controller.imageViewText = self.cardContainerView.titleLabel.text;
    controller.bottomShareText = NSLocalizedString(@"Share with friends on...", nil);
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma -mark HomeContainerView
- (void)homeView:(UIView *)view tappedButtonNumber:(int)number forType:(QuestionType)type
{
    // number will be button 1 or button 2
    DLog(@"tapped button %d",number);
    [self doneChoosing];
    
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
    NSArray *options = @[[NSNumber numberWithInt:QuestionTypeAorB],[NSNumber numberWithInt:QuestionTypeYESorNO]];
    id type = options[arc4random_uniform([options count])];
    int typeInt = [(NSNumber *)type intValue];
    card.questionType = typeInt;
    
    if (card.questionType == QuestionTypeAorB){
        self.cardContainerView.imageView.image = [UIImage imageNamed:@"test2"];
        self.cardContainerView.titleLabel.text = @"Rhianna or Beyonce?";
    }
    else{
        self.cardContainerView.imageView.image = [UIImage imageNamed:@"test"];
        self.cardContainerView.titleLabel.text = @"Do these jeans look good on me?";
    }
    
    // grab data from url
    // live version should just need to grab id and fetch from server (maybe)
    NSString *url = data[@"card_url"];
    NSString *title = data[@"question"];
    NSString *username = data[@"user"];
    NSString *votes = data[@"votes"];
    //NSString *questionType = data[@"question_type"];
    
    [self.cardContainerView.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"cedric"]];
    self.cardContainerView.countLabel.text = @"1/1";
    self.cardContainerView.titleLabel.text = title;
    self.cardContainerView.votesTotalLabel.text = [NSString stringWithFormat:@"%@ Votes",votes];
    self.cardContainerView.userLabel.text = username;
    self.cardContainerView.delegate = self;
    self.navbar.topItem.title = title;
    
}

- (HomeContainerView *)cardContainerView
{
    if (!_cardContainerView){
        _cardContainerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeContainerView" owner:self options:nil] objectAtIndex:0];
        _cardContainerView.frame = CGRectMake(0,60,self.view.frame.size.width, self.view.frame.size.height - 60);
        [self.view addSubview:_cardContainerView];
    }
    
    return _cardContainerView;
}

@end
