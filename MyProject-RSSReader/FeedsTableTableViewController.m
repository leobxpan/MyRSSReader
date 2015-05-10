//
//  FeedsTableTableViewController.m
//  MyProject-RSSReader
//
//  Created by Caesar on 15/2/25.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "FeedsTableTableViewController.h"

@interface FeedsTableTableViewController ()

@property NSMutableDictionary *currentSection;                                  //The currently parsed section.
@property NSMutableString *storyString;                                         //The appending string while parsing.
@property NSMutableArray *feeds;                                                //The original RSS feeds.
@property NSMutableArray *feedInformation;                                      //I store parsed data here.
@property NSMutableDictionary *parserDictionary;                                //I use parser as an identifier.
@property (strong,nonatomic) NSMutableArray *filteredFeedsTitleArray;           //Used to store the feeds filtered by the keyword.
@property (strong, nonatomic) IBOutlet UISearchBar *feedSearchBar;

@end

@implementation FeedsTableTableViewController

static int recordOrder = 0;
static int recordViewAppear = 0;

-(void)viewWillAppear:(BOOL)animated
{
    if((!recordViewAppear) && ([collectArticles sharedInstance].recordAddedNewFeedsOrNot - [collectArticles sharedInstance].helpRecordAddedNewFeedsOrNot)){         //If we have added a new feed, then we need to reload the tableview.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    recordViewAppear = 1;
    [collectArticles sharedInstance].helpRecordAddedNewFeedsOrNot = 0;
    [collectArticles sharedInstance].recordAddedNewFeedsOrNot = 0;
    
    //Some initialization.
    self.filteredFeedsTitleArray = [NSMutableArray arrayWithCapacity:[self.feeds count]];
    self.feedInformation = [NSMutableArray array];
    self.parserDictionary = [NSMutableDictionary dictionary];
    NSArray *array = @[
                     @"http://images.apple.com/main/rss/hotnews/hotnews.rss",
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

    //Asynchronously start parsing RSS feeds.
    for(int i=0;i<[[collectArticles sharedInstance].RSSfeeds count];i++){
        [self getData:[collectArticles sharedInstance].RSSfeeds[i]];
    }
    
}

//Swipe to call out the sidebar.
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    NSArray *images = @[
                        [UIImage imageNamed:@"collect"]
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.delegate = self;
    [callout show];
    
}

//An equivalent of the swipe gesture above.
- (IBAction)clickBurger
{
    NSArray *images = @[
                        [UIImage imageNamed:@"collect"]
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.delegate = self;
    [callout show];

}

//Actions when clicking on different items in sidebar.
- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index
{
    if (index == 0) {
        [sidebar dismissAnimated:NO];
        [self performSegueWithIdentifier:@"showCollectedArticles" sender:nil];
    }
}

//About what RSS parser does.
-(void)getData : (NSString *)urlString
{
    //Generate a url request.
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Initialize the parser.
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
        //When an error occurs while parsing.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loading Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        
    }];
    
    //Start parsing.
    [operation start];
    
}

//Launch when the parser start parsing a new document.
-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.storyString = [[NSMutableString alloc]init];
    self.currentSection = [NSMutableDictionary dictionary];
}

//Launch when the parser encounters a new tag, which in RSS files is surrounded by <>.
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"]){

        [self.feedInformation addObject:[self.currentSection mutableCopy]];

        //Due to the Asynchronous loading pattern, I need some measures to help me figure out the correct order of the feeds so I can put them on table view correctly.
        self.feedInformation[recordOrder][@"url"] = parser;
        recordOrder++;
        
        [parser abortParsing];
        [self.tableView reloadData];
    }
}

//Launch when the parser encounters the characters between two tags.
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.storyString appendString:string];
}

//Launch when the parser encounters an ending tag.
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(elementName){
        if([elementName isEqualToString:@"title"]){
            if([collectArticles sharedInstance].feedsTitleArray == nil){
                [collectArticles sharedInstance].feedsTitleArray = [NSMutableArray array];
                [[collectArticles sharedInstance].feedsTitleArray addObject:[[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy]];
            }else{
                //The title may appear multiply times, so I do the following judgements.
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView) {          //This means the current view is the search view.
        return [self.filteredFeedsTitleArray count];
    }else{
        return [self.feedInformation count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //I may always need to do the following initialization.
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

//The following implements the swipe-delete function.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        [self performSegueWithIdentifier:@"showArticles" sender:tableView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

//The following three functions are about the search bar.
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
