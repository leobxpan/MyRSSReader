//
//  StoryTableViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/21.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "StoryTableViewController.h"

@interface StoryTableViewController ()

@property NSDictionary *stories;
@property NSMutableDictionary *currentSection;
@property NSMutableDictionary *tempData;
@property NSMutableString *storyString;
@property NSMutableArray *itemArray;
@property NSMutableArray *filteredArticlesTitleArray;
@property NSMutableArray *articlesTitleArray;
@property (strong, nonatomic) IBOutlet UISearchBar *articleSearchBar;

@end

@implementation StoryTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.articlesTitleArray = [NSMutableArray array];
    self.filteredArticlesTitleArray = [NSMutableArray array];
    if(![collectArticles sharedInstance].haveReadArticlesUrls){
        [collectArticles sharedInstance].haveReadArticlesUrls = [NSMutableArray array];
    }
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self getData : self.urlString];
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    NSArray *images = @[
                        [UIImage imageNamed:@"collect"]
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.delegate = self;
    [callout show];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    if (index == 0) {
        [sidebar dismissAnimated:NO];
        [self performSegueWithIdentifier:@"showCollectedArticles" sender:nil];
    }
}

-(void)getData : (NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];    

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        [XMLParser setShouldProcessNamespaces:YES];
        XMLParser.delegate = self;
        [XMLParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        
    }];
    
    [operation start];

}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    self.stories = [[NSDictionary alloc]init];
    self.tempData = [NSMutableDictionary dictionary];
    self.storyString = [[NSMutableString alloc]init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"channel"]){
        self.currentSection = [NSMutableDictionary dictionary];
    }else if([elementName isEqualToString:@"item"]){
        [self.currentSection removeAllObjects];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.storyString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"channel"]){
        self.stories = @{@"stories":self.tempData};
        self.tempData = nil;
    }else if([elementName isEqualToString:@"item"]){
        if(self.tempData[@"item"]){
            self.itemArray = self.tempData[@"item"];
        }else{
            self.itemArray = [NSMutableArray array];
        }
        [self.itemArray addObject:[self.currentSection mutableCopy]];
        self.currentSection = [NSMutableDictionary dictionary];
        self.tempData[@"item"] = self.itemArray;
    }else if([elementName isEqualToString:@"title"]){
        self.currentSection[elementName] = [[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
            if(![[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[self.articlesTitleArray lastObject]]){
                if(![[self.articlesTitleArray lastObject] isEqualToString:self.currentFeedTitle]){
                    [self.articlesTitleArray addObject:[[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy]];
                }
            }
        self.storyString = [NSMutableString string];
    }
    else if(elementName){
        self.currentSection[elementName] = [[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
        self.storyString = [NSMutableString string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredArticlesTitleArray count];
    }else{
        return [self.itemArray count];
    }

    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"story";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = self.filteredArticlesTitleArray[indexPath.row];
    }else{
        NSArray *array = [self.itemArray copy];
        NSString *noWhiteSpaceTitle = [array[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.textLabel.text = noWhiteSpaceTitle;
        for(NSString *url in [collectArticles sharedInstance].haveReadArticlesUrls){
            if([url isEqualToString:array[indexPath.row][@"link"]]){
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.searchDisplayController.searchResultsTableView){
        [self performSegueWithIdentifier:@"showStory" sender:tableView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showStory"]) {
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            NSString *title = self.filteredArticlesTitleArray[indexPath.row];
            for(int i=0;i<[self.itemArray count];i++){
                if([title isEqualToString:[self.itemArray[i][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
                    NSString *url = self.itemArray[i][@"link"];
                    [[segue destinationViewController] setUrl:[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    [[segue destinationViewController] setCollectFunc:[[collectArticles sharedInstance]initWithTempArticles:[@{[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]}mutableCopy]]];
                }
            }
        }else{NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSArray *array = [self.itemArray copy];
            NSString *string = [array[indexPath.row][@"link"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [[collectArticles sharedInstance].haveReadArticlesUrls addObject:string];
            [[segue destinationViewController] setUrl:string];
            [[segue destinationViewController] setCollectFunc:[[collectArticles sharedInstance]initWithTempArticles:[@{[array[indexPath.row][@"link"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : [array[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]}mutableCopy]]];
        }
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredArticlesTitleArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    self.filteredArticlesTitleArray = [NSMutableArray arrayWithArray:[self.articlesTitleArray filteredArrayUsingPredicate:predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end