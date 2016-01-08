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


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.question forKey:@"question"];
    [aCoder encodeObject:self.imgUrl forKey:@"imgUrl"];
    [aCoder encodeObject:self.senderImgUrl forKey:@"senderImgUrl"];
    [aCoder encodeObject:self.senderName forKey:@"senderName"];
    [aCoder encodeObject:self.senderFbID forKey:@"senderFbID"];
    [aCoder encodeObject:self.percentVotesLeft forKey:@"percentVotesLeft"];
    [aCoder encodeObject:self.percentVotesRight forKey:@"percentVotesRight"];
    [aCoder encodeObject:self.voteCount forKey:@"voteCount"];
    [aCoder encodeObject:self.created forKey:@"created"];
    [aCoder encodeObject:self.questionType forKey:@"questionType"];
    [aCoder encodeObject:self.selectionNumber forKey:@"selectionNumber"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.id = [aDecoder decodeObjectForKey:@"id"];
    self.question = [aDecoder decodeObjectForKey:@"question"];
    self.imgUrl = [aDecoder decodeObjectForKey:@"imgUrl"];
    self.senderImgUrl = [aDecoder decodeObjectForKey:@"senderImgUrl"];
    self.senderName = [aDecoder decodeObjectForKey:@"senderName"];
    self.senderFbID = [aDecoder decodeObjectForKey:@"senderFbID"];
    self.percentVotesLeft = [aDecoder decodeObjectForKey:@"percentVotesLeft"];
    self.percentVotesRight = [aDecoder decodeObjectForKey:@"percentVotesRight"];
    self.voteCount = [aDecoder decodeObjectForKey:@"voteCount"];
    self.created = [aDecoder decodeObjectForKey:@"created"];
    self.questionType = [aDecoder decodeObjectForKey:@"questionType"];
    self.selectionNumber = [aDecoder decodeObjectForKey:@"selectionNumber"];
    
    
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
        
        NSString *createdString = data[@"created"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormat setLocale:[NSLocale currentLocale]];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDate *date = [dateFormat dateFromString:createdString];
        
        card.created = date;
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
