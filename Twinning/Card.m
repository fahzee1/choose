//
//  Card.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/7/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)init
{
    self = [super init];
    if (self){
        self.questionType = QuestionTypeNone;
        self.question = @"Is Hotline Bling the song of 2015?";
        self.voteCount = @(1172);
        self.imgUrl = [NSURL URLWithString:@"http://assets.audiomack.com/djsinatra/85747f05cbff570c1815db275f42d34a.jpeg"];
        self.senderName = @"Twinning Team";
        self.senderImgUrl = [NSURL URLWithString:@"http://static.comicvine.com/uploads/original/4/43369/1135029-0000034668_20061021010455.jpg"];
        self.id = @"44";
        
    }
    return self;
}


- (NSString *)voteCountString
{
    NSString *string = [NSString stringWithFormat:@"%@ Votes",self.voteCount];
    return NSLocalizedString(string, nil);
}
@end
