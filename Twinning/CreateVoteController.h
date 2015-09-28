//
//  CreateVoteController.h
//  Twinning
//
//  Created by CJ Ogbuehi on 9/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, VoteStage){
    VoteStage1,
    VoteStage2,
    VoteStage3,
    VoteStage4,
    VoteStage5,
    
};

@interface CreateVoteController : UIViewController

@property(assign) VoteStage stage;

@end
