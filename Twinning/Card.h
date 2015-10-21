//
//  Card.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/7/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, QuestionType){
    QuestionTypeNone,
    QuestionTypeYESorNO,
    QuestionTypeAorB
};

@interface Card : NSObject

@property (strong,nonatomic) NSString *question;
@property (strong,nonatomic) NSURL *imgUrl;
@property (strong,nonatomic) NSURL *senderImgUrl;
@property (strong,nonatomic) NSString *senderName;
@property (strong,nonatomic) NSNumber *percentVotesLeft;
@property (strong,nonatomic) NSNumber *percentVotesRight;
@property (strong,nonatomic) NSNumber *voteCount;
@property (strong,nonatomic) NSNumber *voteResult;
@property (assign) QuestionType questionType;

- (NSString *)voteCountString;


@end
