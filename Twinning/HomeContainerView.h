//
//  HomeContainerView.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/5/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@class HomeContainerView;

@protocol HomeContainerDelegate <NSObject>

- (void)homeView:(HomeContainerView *)view tappedButtonNumber:(int)number forType:(QuestionType)type;
- (void)homeView:(HomeContainerView *)view tappedShareImage:(UIImage *)img withTitle:(NSString *)title;
- (void)homeView:(HomeContainerView *)view tappedFullScreenImage:(UIImage *)img;
- (void)homeViewTappedUserContainer:(HomeContainerView *)view;

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

@property (assign)BOOL showCheckOnLargerPercentage;

@property (strong,nonatomic) Card *card;

/**
 Reset view do default state - renable buttons and hide results
 */
- (void)reset;
- (void)dismiss;

/**
 hide buttons to only be seen once the images is loaded
 */
- (void)hideButtons;
/**
 display bottom buttons for cards
 */
- (void)showButtons;

/**
 show results from cache 
 */
- (void)showCachedResults;

@end
