//
//  collectArticles.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/27.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "collectArticles.h"

@interface collectArticles()

@end

@implementation collectArticles

+(collectArticles *)sharedInstance{
    static collectArticles *sharedMyCollectArticles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyCollectArticles = [[self alloc] init];
    });
    return sharedMyCollectArticles;
}

-(collectArticles *)initWithTempArticles:(NSMutableDictionary *)tempArticles{
    self = [super init];
    if(self){
        self.tempArticles = tempArticles;
    }
    return self;
}

@end
