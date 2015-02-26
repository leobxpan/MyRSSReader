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

@end

@implementation FeedsTableTableViewController

static int recordOrder = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedInformation = [NSMutableArray array];
    self.parserDictionary = [NSMutableDictionary dictionary];
    self.feeds = [[NSMutableArray alloc]initWithObjects:
                  @"http://images.apple.com/main/rss/hotnews/hotnews.rss",
                  @"http://songshuhui.net/feed",
                  @"http://meiwenrishang.com/rss",
                  @"http://www.zhihu.com/rss",
                  @"http://www.matrix67.com/blog/feed",
                  @"http://www.nbweekly.com/rss/smw/",
                  @"http://zaobao.feedsportal.com/c/34003/f/616931/index.rss",
                  @"http://zaobao.feedsportal.com/c/34003/f/616930/index.rss",
                  nil];
    //NSLog(@"%@_%@_%@",self.feeds[0],self.feeds[1],self.feeds[2]);
    //NSLog(@"%lu",self.feeds.count);
    for(int i=0;i<[self.feeds count];i++){
        [self getData:self.feeds[i]];
        //NSLog(@"%@",self.feeds[i]);
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        //NSLog(@"%lu",[self.feedInformation count]);
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.storyString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if(elementName){
        self.currentSection[elementName] = [[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
        self.storyString = [NSMutableString string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    //NSLog(@"%@",self.feedInformation[1][@"title"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //NSLog(@"%lu",[self.feedInformation count]);

    return [self.feedInformation count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feed" forIndexPath:indexPath];
    NSString *noWhiteSpaceTitle = [self.feedInformation[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.textLabel.text = noWhiteSpaceTitle;
    
    //NSLog(@"%@-%lu",cell.textLabel.text,indexPath.row);
    //if(indexPath.row == 1){
     //   NSLog(@"%@",noWhiteSpaceTitle);
    //}
    //NSLog(@"%@",self.feedInformation[0][@"title"]);
    //if([self.feedInformation count] > 1){
    //  NSLog(@"%@",self.feedInformation[1][@"title"]);
    //}
    // Configure the cell...
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showArticles"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //[[segue destinationViewController] setUrlString :
        NSXMLParser *symbolParser = self.feedInformation[indexPath.row][@"url"];
        for(NSString *url in [self.parserDictionary allKeys]){
           // NSLog(@"%@",url);
            //NSLog(@"%@-%@",self.parserDictionary[url],symbolParser);
            
            if(self.parserDictionary[url] == symbolParser){
                //NSLog(@"1");
                [[segue destinationViewController] setUrlString:url];
            }
        }
        //NSLog(@"%@-%lu",self.feeds[indexPath.row],indexPath.row);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/

@end
