//
//  NSDictionary+JSONReturnValues.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/3/5.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "NSDictionary+JSONReturnValues.h"

@implementation NSDictionary(JSONReturnValues)

-(NSArray *)returnEveryResultArray{
    NSArray *resultArray = self[@"results"];
    return resultArray;
}

@end
