//
//  HomeErrorView.h
//  Choose
//
//  Created by CJ Ogbuehi on 12/8/15.
//  Copyright © 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeErrorView;

@protocol HomeErrorViewDelegate <NSObject>

- (void)homeErrorViewTappedButton:(HomeErrorView *)view;

@end
@interface HomeErrorView : UIView

@property (weak,nonatomic) id<HomeErrorViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end
