//
//  collectArticles.h
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/27.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface collectArticles : NSObject

@property NSMutableDictionary *tempArticles;
@property NSMutableDictionary *collectedArticles;
@property NSArray *sideBarImages;
@property NSArray *sideBarImagesNames;
@property NSMutableArray *haveReadArticlesUrls;
@property NSMutableArray *RSSfeeds;
@property NSMutableArray *feedsTitleArray;
@property NSInteger *recordAddedNewFeedsOrNot;
@property NSInteger *helpRecordAddedNewFeedsOrNot;

+(collectArticles *)sharedInstance;
-(collectArticles *)initWithTempArticles : (NSMutableDictionary *)tempArticles;

@end
