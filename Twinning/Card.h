//
//  Card.h
//  Twinning
//
//  Created by CJ Ogbuehi on 10/7/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QuestionType){
     QuestionTypeAorB = 100,
    QuestionTypeYESorNO,
};

@interface Card : NSObject 

@property (strong,nonatomic) NSNumber *id;
@property (strong,nonatomic) NSString *question;
@property (strong,nonatomic) NSURL *imgUrl;
@property (strong,nonatomic) NSURL *senderImgUrl;
@property (strong,nonatomic) NSString *senderName;
@property (strong,nonatomic) NSString *senderFbID;
@property (strong,nonatomic) NSNumber *percentVotesLeft;
@property (strong,nonatomic) NSNumber *percentVotesRight;
@property (strong,nonatomic) NSNumber *voteCount;
@property (strong,nonatomic) NSDate *created;
@property (strong, nonatomic) NSNumber *questionType;
@property (strong, nonatomic) NSNumber *selectionNumber;

- (NSString *)voteCountString;
- (NSURL *)facebookImageUrl;

+ (Card *)createCardWithData:(NSDictionary *)data;

@end
