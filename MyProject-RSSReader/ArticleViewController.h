//
//  ArticleViewController.h
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/26.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *articleTitle;
@property (strong, nonatomic) IBOutlet UITextView *articleBody;
@property NSString *articleTitleString;
@property NSString *articleBodyString;

@end
