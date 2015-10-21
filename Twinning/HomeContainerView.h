//
//  HomeContainerView.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/5/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"


@protocol HomeContainerDelegate <NSObject>

- (void)homeView:(UIView *)view tappedButtonNumber:(int)number forType:(QuestionType)type;
- (void)homeView:(UIView *)view tappedShareImage:(UIImage *)img withTitle:(NSString *)title;
@end

@interface HomeContainerView : UIView
@property (weak) id<HomeContainerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *votesTotalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;

@property (strong,nonatomic) Card *card;

- (void)dismiss;
@end
