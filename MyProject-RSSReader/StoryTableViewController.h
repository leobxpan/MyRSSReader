//
//  StoryTableViewController.h
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/21.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "StoryDetailViewController.h"
#import "ArticleViewController.h"

@interface StoryTableViewController : UITableViewController<NSXMLParserDelegate>

@property NSString *urlString;

@end
