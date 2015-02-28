//
//  StoryDetailViewController.h
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/24.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "collectArticles.h"
#import <RNFrostedSidebar.h>

@interface StoryDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy,nonatomic) NSString *url;
@property collectArticles *collectFunc;

@end

