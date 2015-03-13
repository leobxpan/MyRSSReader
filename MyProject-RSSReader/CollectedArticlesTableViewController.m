//
//  CollectedArticlesTableViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/28.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "CollectedArticlesTableViewController.h"

@interface CollectedArticlesTableViewController ()

@end

@implementation CollectedArticlesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[collectArticles sharedInstance].collectedArticles allKeys]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectedArticle" forIndexPath:indexPath];
    
    for(NSString *urlKey in [[collectArticles sharedInstance].collectedArticles allKeys]){
        if([urlKey isEqualToString:[[collectArticles sharedInstance].collectedArticles allKeys][indexPath.row]]){
            cell.textLabel.text = [collectArticles sharedInstance].collectedArticles[urlKey];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[collectArticles sharedInstance].collectedArticles removeObjectForKey:[[collectArticles sharedInstance].collectedArticles allKeys][indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *string = @"";
    if ([[segue identifier] isEqualToString:@"showCollectedArticle"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        for(NSString *urlKey in  [[collectArticles sharedInstance].collectedArticles allKeys]){
            if([urlKey isEqualToString:[[collectArticles sharedInstance].collectedArticles allKeys][indexPath.row]]){
                string = urlKey;
            }
        }
        [[segue destinationViewController] setUrl:string];
    }
}

@end
