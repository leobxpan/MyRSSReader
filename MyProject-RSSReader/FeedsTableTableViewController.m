//
//  FeedsTableTableViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/25.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "FeedsTableTableViewController.h"

@interface FeedsTableTableViewController ()

@property NSMutableDictionary *currentSection;
@property NSMutableString *storyString;
@property NSMutableArray *feeds;
@property NSMutableArray *feedInformation;
@property NSMutableDictionary *parserDictionary;
@property (strong,nonatomic) NSMutableArray *filteredFeedsTitleArray;
@property (strong, nonatomic) IBOutlet UISearchBar *feedSearchBar;

@end

@implementation FeedsTableTableViewController

static int recordOrder = 0;
static int recordViewAppear = 0;

-(void)viewWillAppear:(BOOL)animated{
    if((!recordViewAppear) && ([collectArticles sharedInstance].recordAddedNewFeedsOrNot - [collectArticles sharedInstance].helpRecordAddedNewFeedsOrNot)){
        [self.feedInformation removeAllObjects];
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        [collectArticles sharedInstance].helpRecordAddedNewFeedsOrNot = [collectArticles sharedInstance].recordAddedNewFeedsOrNot;
        for(int i=0;i<[[collectArticles sharedInstance].RSSfeeds count];i++){
            [self getData:[collectArticles sharedInstance].RSSfeeds[i]];
        }
        [self.tableView reloadData];
    }
    recordViewAppear = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    recordViewAppear = 1;
    [collectArticles sharedInstance].helpRecordAddedNewFeedsOrNot = 0;
    [collectArticles sharedInstance].recordAddedNewFeedsOrNot = 0;
    self.filteredFeedsTitleArray = [NSMutableArray arrayWithCapacity:[self.feeds count]];
    
    self.feedInformation = [NSMutableArray array];
    self.parserDictionary = [NSMutableDictionary dictionary];
    NSArray *array = @[@"http://images.apple.com/main/rss/hotnews/hotnews.rss",
                     @"http://songshuhui.net/feed",
                     @"http://meiwenrishang.com/rss",
                     @"http://www.zhihu.com/rss",
                     @"http://www.matrix67.com/blog/feed",
                     @"http://www.nbweekly.com/rss/smw/",
                     @"http://zaobao.feedsportal.com/c/34003/f/616931/index.rss",
                     @"http://zaobao.feedsportal.com/c/34003/f/616930/index.rss"
                       ];
    if(![collectArticles sharedInstance].RSSfeeds){
        [collectArticles sharedInstance].RSSfeeds = [[NSMutableArray alloc]initWithArray:array];
    }
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];

    for(int i=0;i<[[collectArticles sharedInstance].RSSfeeds count];i++){
        [self getData:[collectArticles sharedInstance].RSSfeeds[i]];
    }
}
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    
    NSArray *images = @[
                        [UIImage imageNamed:@"collect"]
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.delegate = self;
    [callout show];
    
}


- (IBAction)clickBurger {
    
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
        [self.parserDictionary setObject:XMLParser forKey:urlString];
        [XMLParser setShouldProcessNamespaces:YES];
        XMLParser.delegate = self;
        [XMLParser parse];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Data"
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
    self.storyString = [[NSMutableString alloc]init];
    self.currentSection = [NSMutableDictionary dictionary];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"item"]){
        [self.feedInformation addObject:[self.currentSection mutableCopy]];
        self.currentSection = [NSMutableDictionary dictionary];
        self.feedInformation[recordOrder][@"url"] = parser;
        recordOrder++;
        [parser abortParsing];
        [self.tableView reloadData];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.storyString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if(elementName){
        if([elementName isEqualToString:@"title"]){
            if([collectArticles sharedInstance].feedsTitleArray == nil){
                [collectArticles sharedInstance].feedsTitleArray = [NSMutableArray array];
                [[collectArticles sharedInstance].feedsTitleArray addObject:[[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy]];
            }else{
                int recordIfTitleHasBeenAround = 0;
                for(int i=0;i<[[collectArticles sharedInstance].feedsTitleArray count];i++){
                    if([[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[collectArticles sharedInstance].feedsTitleArray[i]]){
                        recordIfTitleHasBeenAround = 1;
                        break;
                    }
                }
                if(!recordIfTitleHasBeenAround){
                    [[collectArticles sharedInstance].feedsTitleArray addObject:[[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy]];
                }
            }
        }
        self.currentSection[elementName] = [[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy];
        self.storyString = [NSMutableString string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredFeedsTitleArray count];
    }else{
        return [self.feedInformation count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"feed";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *noWhiteSpaceTitle = [self.feedInformation[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = self.filteredFeedsTitleArray[indexPath.row];
    }else{
        cell.textLabel.text = noWhiteSpaceTitle;
    }
    if(indexPath.row == ([[collectArticles sharedInstance].RSSfeeds count]-1)){
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *deletedArticleTitle = self.feedInformation[indexPath.row][@"title"];
        for(int i=0;i<[[collectArticles sharedInstance].feedsTitleArray count];i++){
            if([[collectArticles sharedInstance].feedsTitleArray[i] isEqualToString:deletedArticleTitle]){
                [[collectArticles sharedInstance].feedsTitleArray removeObjectAtIndex:i];
            }
        }
        [self.feedInformation removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.searchDisplayController.searchResultsTableView){
        [self performSegueWithIdentifier:@"showArticles" sender:tableView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showArticles"]) {
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            NSString *title = self.filteredFeedsTitleArray[indexPath.row];
            for(int i=0;i<[self.feedInformation count];i++){
                if([title isEqualToString:self.feedInformation[i][@"title"]]){
                    NSXMLParser *symbolParser = self.feedInformation[i][@"url"];
                    for(NSString *url in [self.parserDictionary allKeys]){
                        if(self.parserDictionary[url] == symbolParser){
                            [[segue destinationViewController] setUrlString:url];
                            [[segue destinationViewController] setCurrentFeedTitle:self.feedInformation[indexPath.row][@"title"]];
                        }
                    }
                }
            }
        }else{
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSXMLParser *symbolParser = self.feedInformation[indexPath.row][@"url"];
            for(NSString *url in [self.parserDictionary allKeys]){
                if(self.parserDictionary[url] == symbolParser){
                    [[segue destinationViewController] setUrlString:url];
                }
            }
        }
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.filteredFeedsTitleArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    self.filteredFeedsTitleArray = [NSMutableArray arrayWithArray:[[collectArticles sharedInstance].feedsTitleArray filteredArrayUsingPredicate:predicate]];
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

-(void)viewWillDisappear:(BOOL)animated{
    recordOrder = 0;
}
@end
