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
        self.questionType = [NSNumber numberWithInt:101];
        self.question = @"Is Hotline Bling the song of 2015?";
        self.voteCount = [NSNumber numberWithInt:200];
        self.imgUrl = [NSURL URLWithString:@"http://assets.audiomack.com/djsinatra/85747f05cbff570c1815db275f42d34a.jpeg"];
        self.senderName = @"Twinning Team";
        self.senderImgUrl = [NSURL URLWithString:@"http://static.comicvine.com/uploads/original/4/43369/1135029-0000034668_20061021010455.jpg"];
        self.id = [NSNumber numberWithInt:404];
        
    }
    return self;
}

- (NSString *)description
{
    return self.question;
}

+ (Card *)createCardWithData:(NSDictionary *)data
{
    Card *card = nil;
    if (data){
        card = [[Card alloc] init];
        card.id = data[@"id"];
        card.question = data[@"question"];
        card.questionType = data[@"question_type"];
        card.imgUrl = [NSURL URLWithString:data[@"image"]];
        card.senderName = data[@"user"][@"username"];
        card.senderFbID = data[@"user"][@"facebook_id"];
        card.percentVotesLeft = data[@"percentage"][@"left"];
        card.percentVotesRight = data[@"percentage"][@"right"];
        card.voteCount = data[@"total_votes"];
        
    }
    
    return card;
}

- (NSURL *)facebookImageUrl
{
    NSURL *fbUrl;
    if ([self.senderFbID intValue]){
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.senderFbID];
        fbUrl = [NSURL URLWithString:fbString];
        
    }
    
    return fbUrl;
}

- (NSString *)voteCountString
{
    NSString *string = [NSString stringWithFormat:@"%@ Votes",self.voteCount];
    return NSLocalizedString(string, nil);
}

@end
