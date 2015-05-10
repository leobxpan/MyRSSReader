//
//  SearchFeedsTableViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/3/5.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "SearchFeedsTableViewController.h"

@interface SearchFeedsTableViewController ()

@property NSDictionary *searchedFeedsTitles;                                //Store
@property (strong, nonatomic) IBOutlet UISearchBar *searchRSSFeeds;         //Here I use a search bar in which users type the keywords.
@property NSString *searchedString;                                         //The keywords user input.

@end

@implementation SearchFeedsTableViewController

static int recordFeedHasBeenAddedOrNot = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchDisplayController.delegate = self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    NSString *searchString = [@"http://cloud.feedly.com/v3/search/feeds?query=" stringByAppendingString:self.searchedString];           //This is a public free API to search RSS feeds based on the keywords.
    [self getData:searchString];
    [self.searchRSSFeeds resignFirstResponder];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchRSSFeeds becomeFirstResponder];
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.searchedString = searchText;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

-(void)getData : (NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];           //This time the data is in json form.

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        self.searchedFeedsTitles = (NSDictionary *)responseObject;
        [self.searchDisplayController.searchResultsTableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retriving Feeds"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchedFeedsTitles[@"results"] count];
}

//Select to add a feed, so this function deals with affairs when adding new feeds.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        NSMutableString *mutableTitle = [[NSMutableString alloc] initWithString:self.searchedFeedsTitles[@"results"][indexPath.row][@"feedId"]];
        NSRange deleteRange = [mutableTitle rangeOfString:@"feed/"];
        [mutableTitle deleteCharactersInRange:deleteRange];
        for(int i=0;i<[[collectArticles sharedInstance].feedsTitleArray count];i++){
            if([[collectArticles sharedInstance].feedsTitleArray[i] isEqualToString:[self.searchedFeedsTitles[@"results"][indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
                recordFeedHasBeenAddedOrNot = 1;
                break;
            }
        }
        if(recordFeedHasBeenAddedOrNot){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"该RSS源已经存在，请勿重复添加"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else{
            [[collectArticles sharedInstance].RSSfeeds addObject:mutableTitle];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RSS源添加成功！"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [collectArticles sharedInstance].recordAddedNewFeedsOrNot++;
            [alertView show];
        }
    }
    recordFeedHasBeenAddedOrNot = 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResult"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResult"];
    }
    if(indexPath.row == 4){
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }
    cell.textLabel.text = [self.searchedFeedsTitles[@"results"][indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//[self.searchedFeedsTitles returnEveryResultArray][indexPath.row][@"title"];
    return cell;
}

@end
