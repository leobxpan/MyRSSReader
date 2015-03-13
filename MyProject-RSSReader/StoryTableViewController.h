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
#import "collectArticles.h"
#import <SWTableViewCell.h>
#import <RNFrostedSidebar.h>
#import <MBProgressHUD.h>

@interface StoryTableViewController : UITableViewController<NSXMLParserDelegate>//,SWTableViewCellDelegate>

@property NSString *urlString;
@property NSString *currentFeedTitle;

@end
