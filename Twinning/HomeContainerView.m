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

@interface HomeContainerView()
@property (strong,nonatomic) HomeResultView *resultView;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *imageViewTap;


// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelBottomConstraint;

// Constraints

@end
@implementation HomeContainerView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.clipsToBounds = YES;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    self.countLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    self.userLabel.font = [UIFont fontWithName:kFontGlobal size:18];
    self.votesTotalLabel.font = [UIFont fontWithName:kFontGlobal size:18];
    
    self.userContainerView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
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
    
    self.userLabel.textColor = [UIColor whiteColor];
    self.votesTotalLabel.textColor = [UIColor whiteColor];
    
    //use this cover label to add on top of the image to show answer was chosen
    self.resultView = [[[NSBundle mainBundle] loadNibNamed:@"HomeResultView" owner:self options:nil] objectAtIndex:0];
    self.resultView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.resultView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.resultView.leftLabel.text = @"65% chose no";
    self.resultView.rightLabel.text = @"35% chose yes";
    [self.imageView addSubview:self.resultView];
    self.resultView.hidden = YES;
    self.resultView.alpha = 0;
    
    self.shareImageView.userInteractionEnabled = YES;
    self.imageView.userInteractionEnabled = YES;
    self.imageViewTap.numberOfTapsRequired = 2;
    
    FAKIonIcons *shareIcon = [FAKIonIcons shareIconWithSize:15];
    [shareIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    shareIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorDarkGrey];
    UIImage *icon = [shareIcon imageWithSize:CGSizeMake(20, 20)];
    self.shareImageView.image = icon;
    self.shareImageView.layer.cornerRadius = self.shareImageView.frame.size.height/2;
    self.shareImageView.layer.masksToBounds = YES;
    
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

- (void)showImageViewCover
{
    self.shareImageView.hidden = YES;
    self.shareImageView.alpha = 0;
    
    if (self.card.questionType == QuestionTypeYESorNO){
        self.resultView.leftLabel.text = @"65% chose YES";
        self.resultView.rightLabel.text = @"35% chose NO";
    }
    else if (self.card.questionType == QuestionTypeAorB){
        self.resultView.leftLabel.text = @"65% chose A";
        self.resultView.rightLabel.text = @"35% chose B";
    }
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.resultView showLeft];
                        }];
}


- (IBAction)tappedImageView:(UITapGestureRecognizer *)sender {
    if (self.delegate){
        [self.delegate homeView:self
               tappedShareImage:self.imageView.image
                      withTitle:self.titleLabel.text];
    }
    
}

- (IBAction)tappedButton1:(UIButton *)sender {
    [self showImageViewCover];
    
    if (self.delegate){
        [self.delegate homeView:self
             tappedButtonNumber:1
                        forType:self.card.questionType];
    }
}

- (IBAction)tappedButton2:(UIButton *)sender {
    [self showImageViewCover];
    
    if (self.delegate){
        [self.delegate homeView:self
             tappedButtonNumber:2
                        forType:self.card.questionType];
    }
}

- (void)dismiss
{
    [self removeFromSuperview];
    
}

- (void)setCard:(Card *)card
{
    // When i set the card use that to display correct bottom button
    _card = card;
    
    if (card.questionType == QuestionTypeYESorNO){
        [self.button1 setTitle:NSLocalizedString(@"YES", nil) forState:UIControlStateNormal];
        [self.button2 setTitle:NSLocalizedString(@"NO", nil) forState:UIControlStateNormal];
        self.button1.backgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
        self.button2.backgroundColor = [UIColor colorWithHexString:kColorFlatRed];
    }
    else if (card.questionType == QuestionTypeAorB){
        [self.button1 setTitle:NSLocalizedString(@"A", nil) forState:UIControlStateNormal];
        [self.button2 setTitle:NSLocalizedString(@"B", nil) forState:UIControlStateNormal];
        self.button1.backgroundColor = [UIColor colorWithHexString:kColorOrange];
        self.button2.backgroundColor = [UIColor colorWithHexString:kColorFlatBlue];
    }

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
