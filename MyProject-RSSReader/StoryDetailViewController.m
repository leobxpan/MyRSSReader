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

//bool collectedOrNot = NO;
//bool hasBeenCollectedOrNot = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *myURL = [NSURL URLWithString: [self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    //collectedOrNot = NO;
    
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
        //NSLog(@"%@",self.collect.currentTitle);
        //NSLog(@"%@-%@",self.url,urlKey);
            //NSLog(@"1");
        //NSLog(@"%@-%@",urlKey,_collectFunc.collectedArticles[urlKey]);
        //NSLog(@"%@",_collectFunc.collectedArticles[urlKey]);
        if([[urlKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
            _collectFunc.sideBarImages = @[
                                //[UIImage imageNamed:@"gear"],
                                [UIImage imageNamed:@"globe"],
                                //[UIImage imageNamed:@"profile"],
                                [UIImage imageNamed:@"uncollect"]
                                ];
            _collectFunc.sideBarImagesNames = @[
                                @"globe",
                                @"uncollect"
                                ];
            sideBarInitialize = 1;

        }else{
            _collectFunc.sideBarImages = @[
                                           //[UIImage imageNamed:@"gear"],
                                           [UIImage imageNamed:@"globe"],
                                           //[UIImage imageNamed:@"profile"],
                                           [UIImage imageNamed:@"collect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"globe",
                                                @"collect"
                                                ];
            sideBarInitialize = 1;
        }
    }
    if(!sideBarInitialize){
        _collectFunc.sideBarImages = @[
                                       //[UIImage imageNamed:@"gear"],
                                       [UIImage imageNamed:@"globe"],
                                       //[UIImage imageNamed:@"profile"],
                                       [UIImage imageNamed:@"collect"]
                                       ];
        _collectFunc.sideBarImagesNames = @[
                                            @"globe",
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
    if (index == 1) {
        [sidebar dismissAnimated:NO];
        if([_collectFunc.sideBarImagesNames[1] isEqualToString:@"collect"]){
            
            _collectFunc.sideBarImages = @[
                                           //[UIImage imageNamed:@"gear"],
                                           [UIImage imageNamed:@"globe"],
                                           //[UIImage imageNamed:@"profile"],
                                           [UIImage imageNamed:@"uncollect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"globe",
                                                @"uncollect"
                                                ];
            for(NSString *urlkey in [_collectFunc.tempArticles allKeys]){
                [_collectFunc.collectedArticles setObject:_collectFunc.tempArticles[urlkey] forKey:urlkey];
                //NSLog(@"%@",_collectFunc.collectedArticles[urlkey]);
            }
        }else{
            //NSLog(@"1");
            _collectFunc.sideBarImages = @[
                                           //[UIImage imageNamed:@"gear"],
                                           [UIImage imageNamed:@"globe"],
                                           //[UIImage imageNamed:@"profile"],
                                           [UIImage imageNamed:@"collect"]
                                           ];
            _collectFunc.sideBarImagesNames = @[
                                                @"globe",
                                                @"collect"
                                                ];

            [_collectFunc.collectedArticles removeObjectForKey:[self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [_collectFunc.tempArticles removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
