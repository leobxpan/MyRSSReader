//
//  StoryDetailViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/24.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "StoryDetailViewController.h"

@interface StoryDetailViewController ()

@end

@implementation StoryDetailViewController

static int sideBarInitialize = 0;

@synthesize collectFunc = _collectFunc;

-(void)viewWillAppear:(BOOL)animated{
}
- (void)viewDidLoad {
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
                                [UIImage imageNamed:@"uncollect"]
                                ];
            _collectFunc.sideBarImagesNames = @[
                                @"uncollect"
                                ];
            sideBarInitialize = 1;
            break;
        }else{
            _collectFunc.sideBarImages = @[
                                           [UIImage imageNamed:@"collect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"collect"
                                                ];
            sideBarInitialize = 1;
        }
    }
    if(!sideBarInitialize){
        _collectFunc.sideBarImages = @[
                                       [UIImage imageNamed:@"collect"]
                                       ];
        _collectFunc.sideBarImagesNames = @[
                                            @"collect"
                                            ];
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:_collectFunc.sideBarImages];
    callout.delegate = self;
    [callout show];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    if (index == 0) {
        [sidebar dismissAnimated:NO];
        if([_collectFunc.sideBarImagesNames[0] isEqualToString:@"collect"]){
            
            _collectFunc.sideBarImages = @[
                                           [UIImage imageNamed:@"uncollect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"uncollect"
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
                                           [UIImage imageNamed:@"collect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"collect"
                                                ];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"取消收藏成功！"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            [_collectFunc.collectedArticles removeObjectForKey:[self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [_collectFunc.tempArticles removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
