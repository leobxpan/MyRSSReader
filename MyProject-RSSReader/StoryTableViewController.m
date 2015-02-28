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

@end

@implementation StoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData : self.urlString];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)getData : (NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
                  //@"http://songshuhui.net/feed"];
    

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
        
    }];
    
    [operation start];

}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    self.stories = [[NSDictionary alloc]init];
    self.tempData = [NSMutableDictionary dictionary];
    self.storyString = [[NSMutableString alloc]init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"1");
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
        //NSLog(@"%lu",[self.itemArray count]);
        //NSLog(@"%@",self.itemArray[0][@"title"]);
        self.currentSection = [NSMutableDictionary dictionary];
        self.tempData[@"item"] = self.itemArray;
    }else if(elementName){
        self.currentSection[elementName] = [[self.storyString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] copy];
        self.storyString = [NSMutableString string];
        //NSLog(@"%@",self.currentSection[@"title"]);
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //NSLog(@"%lu",[self.itemArray count]);

    return [self.itemArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"story" forIndexPath:indexPath];
    NSArray *array = [self.itemArray copy];
    NSString *noWhiteSpaceTitle = [array[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
       // NSLog(@"%@",noWhiteSpaceTitle);
    cell.textLabel.text = noWhiteSpaceTitle;
    
    //NSLog(@"%@",cell.textLabel.text);
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showStory"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *array = [self.itemArray copy];
        NSString *string = [array[indexPath.row][@"link"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"%@",string);
        [[segue destinationViewController] setUrl:string];
        [[segue destinationViewController] setCollectFunc:[[collectArticles sharedInstance]initWithTempArticles:[@{[array[indexPath.row][@"link"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : [array[indexPath.row][@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]}mutableCopy]]];
        
        //NSLog(@"%@-%@",array[indexPath.row][@"title"],array[indexPath.row][@"p"]);
        //[[segue destinationViewController]setArticleTitleString:array[indexPath.row][@"title"]];
        //[[segue destinationViewController]setArticleBodyString:array[indexPath.row][@"description"]];
    }
}
@end
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


*/

