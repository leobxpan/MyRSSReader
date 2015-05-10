//
//  StoryDetailViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/24.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "StoryDetailViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface StoryDetailViewController ()

@property RNFrostedSidebar *callout;

@end

@implementation StoryDetailViewController

static int sideBarInitialize = 0;

@synthesize collectFunc = _collectFunc;

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    NSURL *myURL = [NSURL URLWithString: [self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;

    if(!_collectFunc.collectedArticles){
        _collectFunc.collectedArticles = [NSMutableDictionary dictionary];
    }
    if(!_collectFunc.sideBarImages){
        _collectFunc.sideBarImages = [NSArray array];
    }
    if(!_collectFunc.sideBarImagesNames){
        _collectFunc.sideBarImagesNames = [NSArray array];
    }
    
    for(NSString *urlKey in [_collectFunc.collectedArticles allKeys]){
        if([[urlKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
            _collectFunc.sideBarImages = @[
                                [UIImage imageNamed:@"uncollect"],
                                [UIImage imageNamed:@"globe"]
                                ];
            _collectFunc.sideBarImagesNames = @[
                                @"uncollect",
                                @"globe"
                                ];
            sideBarInitialize = 1;
            break;
        }else{
            _collectFunc.sideBarImages = @[
                                           [UIImage imageNamed:@"collect"],
                                           [UIImage imageNamed:@"globe"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"collect",
                                                @"globe"
                                                ];
            sideBarInitialize = 1;
        }
    }
    if(!sideBarInitialize){
        _collectFunc.sideBarImages = @[
                                       [UIImage imageNamed:@"collect"],
                                       [UIImage imageNamed:@"globe"]
                                       ];
        _collectFunc.sideBarImagesNames = @[
                                            @"collect",
                                            @"globe"
                                            ];
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    self.callout = [[RNFrostedSidebar alloc] initWithImages:_collectFunc.sideBarImages];
    self.callout.delegate = self;
    [self.callout show];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    [self.callout dismiss];
    if (index == 0) {
        if([_collectFunc.sideBarImagesNames[0] isEqualToString:@"collect"]){
            
            _collectFunc.sideBarImages = @[
                                           [UIImage imageNamed:@"uncollect"],
                                           [UIImage imageNamed:@"globe"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"uncollect",
                                                @"globe"
                                                ];
            for(NSString *urlkey in [_collectFunc.tempArticles allKeys]){
                [_collectFunc.collectedArticles setObject:_collectFunc.tempArticles[urlkey] forKey:urlkey];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"收藏成功！"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else{
            _collectFunc.sideBarImages = @[
                                           [UIImage imageNamed:@"collect"],
                                           [UIImage imageNamed:@"globe"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"collect",
                                                @"globe"
                                                ];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"取消收藏成功！"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            [_collectFunc.collectedArticles removeObjectForKey:[self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }else if(index == 1){
        //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"burger" ofType:@"png"];
        
        //构造分享内容
        NSString *tempString = [_collectFunc.tempArticles[self.url] stringByAppendingString:@" : "];        //Set the default share message.
        NSString *defaultContent = [tempString stringByAppendingString:self.url];
        id<ISSContent> publishContent = [ShareSDK content:defaultContent
                                           defaultContent:defaultContent
                                                    image:nil//[ShareSDK imageWithPath:imagePath]
                                                    title:@"ShareSDK"
                                                      url:@"http://www.mob.com"
                                              description:@""
                                                mediaType:SSPublishContentMediaTypeNews];
        //创建弹出菜单容器
        id<ISSContainer> container = [ShareSDK container];
        //[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
        
        //弹出分享菜单
        [ShareSDK showShareActionSheet:container
                             shareList:nil
                               content:publishContent
                         statusBarTips:YES
                           authOptions:nil
                          shareOptions:nil
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    
                                    if (state == SSResponseStateSuccess)
                                    {
                                        NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                    }
                                    else if (state == SSResponseStateFail)
                                    {
                                        NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                    }
                                }];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [_collectFunc.tempArticles removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
