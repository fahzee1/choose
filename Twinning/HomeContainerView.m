//
//  HomeContainerView.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/5/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "HomeContainerView.h"
#import "HomeResultView.h"
#import "constants.h"
#import "UIColor+HexValue.h"
#import <FAKIonIcons.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ChameleonFramework/Chameleon.h>
#import <AMPopTip.h>

@interface HomeContainerView()
@property (strong,nonatomic) HomeResultView *resultView;

@property (strong,nonatomic) AMPopTip *popTip;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *singleTap;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelBottomConstraint;

@property (assign) BOOL randomColorsSet;

@end
@implementation HomeContainerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self listenForNotifications];
    self.imageView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.imageView.clipsToBounds = YES;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    self.countLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    self.userLabel.font = [UIFont fontWithName:kFontGlobal size:18];
    self.votesTotalLabel.font = [UIFont fontWithName:kFontGlobal size:18];
    
    self.userContainerView.backgroundColor = [UIColor whiteColor];
    self.button1.backgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
    self.button2.backgroundColor = [UIColor colorWithHexString:kColorFlatRed];
    [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.button1.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:25];
    self.button2.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:25];
    

    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            ((UILabel *)view).textColor = [UIColor colorWithHexString:kColorBlackSexy];
        }
    }
    
    self.userLabel.textColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.votesTotalLabel.textColor = [UIColor colorWithHexString:kColorBlackSexy];
    
    // Need this to recieve double tap
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    //use this cover label to add on top of the image to show answer was chosen
    self.resultView = [[[NSBundle mainBundle] loadNibNamed:@"HomeResultView" owner:self options:nil] objectAtIndex:0];
    self.resultView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.resultView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.resultView.leftLabel.text = @"65% chose no";
    self.resultView.rightLabel.text = @"35% chose yes";
    [self.imageView addSubview:self.resultView];
    self.resultView.hidden = YES;
    self.resultView.alpha = 0;
    
    self.imageView.userInteractionEnabled = YES;
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:15];
    [shareIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    shareIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorDarkGrey];
    
    // Ad gesture recognizer for tapping profile
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserProfile)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    UIView *userTapView = [[UIView alloc] init];
    userTapView.frame = CGRectMake(0, 0, self.userContainerView.frame.size.width, self.userContainerView.frame.size.width);
    userTapView.backgroundColor = [UIColor clearColor];
    userTapView.userInteractionEnabled = YES;
    [userTapView addGestureRecognizer:tap];
    [self.userContainerView addSubview:userTapView];
    
    
    [self layoutIfNeeded];
    self.imageViewHeightConstraint.constant = 250;
    self.imageViewWidthConstraint.constant = 250;
    if (IS_IPHONE_4_OR_LESS){
        self.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:17];
        self.countLabel.font = [UIFont fontWithName:kFontGlobal size:13];
        self.userLabel.font = [UIFont fontWithName:kFontGlobal size:15];
        self.votesTotalLabel.font = [UIFont fontWithName:kFontGlobal size:15];
        self.topLabelTopConstraint.constant = 50;
        self.bottomButtonHeightConstraint.constant = 50;
        self.countLabelBottomConstraint.constant = -40;
    }
    if (IS_IPHONE_6 || IS_IPHONE_6P){
        self.imageViewHeightConstraint.constant = 320;
        self.imageViewWidthConstraint.constant = 320;
    }
    [self layoutIfNeeded];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)listenForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTipWithText:) name:kNotificationShowShareImageTip object:nil];
}

- (void)showImageViewCoverForLeft:(BOOL)left
{
    
    if ([self.card.questionType intValue] == QuestionTypeYESorNO){
        self.resultView.leftLabel.text = [NSString stringWithFormat:@"%@%% chose YES",self.card.percentVotesLeft];
        self.resultView.rightLabel.text = [NSString stringWithFormat:@"%@%% chose NO",self.card.percentVotesRight];
    }
    else if ([self.card.questionType intValue] == QuestionTypeAorB){
        self.resultView.leftLabel.text = [NSString stringWithFormat:@"%@%% chose A",self.card.percentVotesLeft];
        self.resultView.rightLabel.text = [NSString stringWithFormat:@"%@%% chose B",self.card.percentVotesRight];
    }
    
    [UIView animateWithDuration:1
                     animations:^{
                         if (left){
                             [self.resultView showLeft];
                         }
                         else{
                             [self.resultView showRight];
                         }
                        }];
}

- (void)showTipWithText:(NSNotification *)notif
{
    NSDictionary *payload = notif.userInfo;
    NSString *text = payload[@"text"];
    
    AMPopTip *appearance = [AMPopTip appearance];
    appearance.textColor = [UIColor whiteColor];
    appearance.font = [UIFont fontWithName:kFontGlobal size:16];
    appearance.popoverColor = [UIColor colorWithHexString:kColorFlatGreen];
    appearance.animationIn = 1;
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTapOutside = YES;
    self.popTip.shouldDismissOnTap = YES;
    
    //CGRect frame = [self.view convertRect:self.selfieImageView.frame fromView:self.topHalfView];
    [self.popTip showText:text direction:AMPopTipDirectionUp maxWidth:300 inView:self fromFrame:self.imageView.frame duration:5];
}

- (void)reset
{
    [self.resultView hide];
    [self reanbleButtons];
    
}

- (void)tappedUserProfile
{
    if (self.delegate){
        [self.delegate homeViewTappedUserContainer:self];
    }
}

- (IBAction)tappedImageViewTwice:(UITapGestureRecognizer *)sender {
    if (self.delegate){
        [self.delegate homeView:self
               tappedShareImage:self.imageView.image
                      withTitle:self.titleLabel.text];
    }
    
}


- (IBAction)tappedImageViewOnce:(UITapGestureRecognizer *)sender {
    if (self.delegate){
        [self.delegate homeView:self
          tappedFullScreenImage:self.imageView.image];
    }
}

- (IBAction)tappedButton1:(UIButton *)sender {
    [self disableButtons];
    [self showImageViewCoverForLeft:YES];
    
    if (self.delegate){
        QuestionType type;
        if ([self.card.questionType intValue] == 100){
            type = QuestionTypeAorB;
        }
        else if ([self.card.questionType intValue] == 101){
            type = QuestionTypeYESorNO;
        }
        
        [self.delegate homeView:self
             tappedButtonNumber:1
                        forType:type];
    }
}

- (IBAction)tappedButton2:(UIButton *)sender {
    [self disableButtons];
    [self showImageViewCoverForLeft:NO];
    
    if (self.delegate){
        QuestionType type;
        if ([self.card.questionType intValue] == 100){
            type = QuestionTypeAorB;
        }
        else if ([self.card.questionType intValue] == 101){
            type = QuestionTypeYESorNO;
        }
        [self.delegate homeView:self
             tappedButtonNumber:2
                        forType:type];
    }
}

- (void)disableButtons
{
    self.button1.userInteractionEnabled = NO;
    self.button2.userInteractionEnabled = NO;
    UIColor *button1Color = self.button1.backgroundColor;
    UIColor *button2Color = self.button2.backgroundColor;
    
    UIColor *button1SelectedColor = [button1Color darkenByPercentage:0.2];
    UIColor *button2SelectedColor = [button2Color darkenByPercentage:0.2];
    
    self.button1.backgroundColor = button1SelectedColor;
    self.button2.backgroundColor = button2SelectedColor;

}

- (void)reanbleButtons
{
    self.button1.userInteractionEnabled = YES;
    self.button2.userInteractionEnabled = YES;
    UIColor *button1Color = self.button1.backgroundColor;
    UIColor *button2Color = self.button2.backgroundColor;
    
    UIColor *button1SelectedColor = [button1Color lightenByPercentage:0.2];
    UIColor *button2SelectedColor = [button2Color lightenByPercentage:0.2];
    
    self.button1.backgroundColor = button1SelectedColor;
    self.button2.backgroundColor = button2SelectedColor;
    
}

- (void)hideButtons
{
    self.button1.alpha = 0;
    self.button1.hidden = YES;
    self.button2.alpha = 0;
    self.button2.hidden = YES;
}
- (void)showButtons
{
    [UIView animateWithDuration:1
                     animations:^{
                         self.button1.alpha = 1;
                         self.button1.hidden = NO;
                         self.button2.alpha = 1;
                         self.button2.hidden = NO;
                     }];
}

- (void)dismiss
{
    [self removeFromSuperview];
    
}

- (void)setCard:(Card *)card
{
    // When i set the card use that to display correct bottom button and set other ui elements
    _card = card;
    
    if ([card.questionType intValue] == QuestionTypeYESorNO){
        [self.button1 setTitle:NSLocalizedString(@"YES", nil) forState:UIControlStateNormal];
        [self.button2 setTitle:NSLocalizedString(@"NO", nil) forState:UIControlStateNormal];
        //self.button1.backgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
        //self.button2.backgroundColor = [UIColor colorWithHexString:kColorFlatRed];
        if (!self.randomColorsSet){
            self.button1.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleDark];
            self.button2.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
            self.randomColorsSet = YES;
        }
    }
    else if ([card.questionType intValue] == QuestionTypeAorB){
        [self.button1 setTitle:NSLocalizedString(@"A", nil) forState:UIControlStateNormal];
        [self.button2 setTitle:NSLocalizedString(@"B", nil) forState:UIControlStateNormal];
        //self.button1.backgroundColor = [UIColor colorWithHexString:kColorOrange];
        //self.button2.backgroundColor = [UIColor colorWithHexString:kColorFlatBlue];
        if (!self.randomColorsSet){
            self.button1.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleDark];
            self.button2.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
            self.randomColorsSet = YES;
        }
    }
    
    self.titleLabel.text = card.question;
    self.votesTotalLabel.text = [card voteCountString];
    self.userLabel.text = card.senderName;
    
    [self.userImageView sd_setImageWithURL:[card facebookImageUrl] placeholderImage:[UIImage imageNamed:kAppPlaceholer]];
    [self.imageView sd_setImageWithURL:card.imgUrl placeholderImage:[UIImage imageNamed:kAppPlaceholer]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [self showButtons];
                             }];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
