//
//  APPMasterViewController.m
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPMasterViewController.h"

#import "APPDetailViewController.h"
#import "/usr/include/sqlite3.h"

@interface APPMasterViewController () {
    NSMutableArray *_objects;
    
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSString *element;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation APPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    feeds = [[NSMutableArray alloc] init];
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc]
                              initWithString: [docsDir stringByAppendingPathComponent:
                                               @"rss.db"]];
    //更新RSS源的openDate字段
    sqlite3_stmt    *statement;
    sqlite3* rssDB;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
    {
        NSString *querySQL =  [NSString stringWithFormat:@"select url,title from content where rss_url=\'%@\'",self.url];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(rssDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                char *urlChars = (char *) sqlite3_column_text(statement, 0);
                char *titleChars = (char *) sqlite3_column_text(statement, 1);

                item = [[NSMutableDictionary alloc] init];
                [item setObject:[NSString stringWithUTF8String:urlChars] forKey:@"link"];
                [item setObject:[NSString stringWithUTF8String:titleChars] forKey:@"title"];
                
                [feeds addObject:item];
                NSLog(@"Read content success");
                
            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"read content  fail");
        }
        sqlite3_close(rssDB);

    }
    NSLog(@"feed count %d",feeds.count);
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    //self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    
    /*
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        feeds = [[NSMutableArray alloc] init];
        NSURL *url = [NSURL URLWithString:self.url];
        NSLog([NSString stringWithFormat:@"master url:%@",url]);
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"hello stop...");
                [self.indicator stopAnimating];
            });
        
    });
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    NSLog(@"text:%@",cell.textLabel.text);
    return cell;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];
        NSLog(@"URL %@",string);
        
    } else {
        NSLog(@"Go back from master");
    }

}

-(void) viewWillDisappear:(BOOL)animated {
    NSLog(@"hello go back");
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        
        
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = [dirPaths objectAtIndex:0];
        NSString *databasePath = [[NSString alloc]
                        initWithString: [docsDir stringByAppendingPathComponent:
                                         @"rss.db"]];
        //更新RSS源的openDate字段
        sqlite3_stmt    *statement;
        sqlite3* rssDB;
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
        {
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString=[dateFormat stringFromDate:[NSDate date]];
            
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"UPDATE rss set opendate=\'%@\',newcount=0 where url=\'%@\'",dateString, self.url];
            NSLog(@"update sql: %@",insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(rssDB, insert_stmt,-1, &statement, NULL);
            

            
            if (sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"ADD SUCCESS");
            } else {
                NSLog(@"Add fail");
            }
            sqlite3_finalize(statement);
            sqlite3_close(rssDB);
        }

        
    }
    [super viewWillDisappear:animated];
}

/*
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        NSLog([@"title=" stringByAppendingString:string]);
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        NSCharacterSet * erase = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString * url = [string stringByTrimmingCharactersInSet:erase];
        if (![[ url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isEqualToString:url]){
            [ link appendString:url];
        } else {
            [ link appendString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        NSLog([@" end title=" stringByAppendingString:title]);
        [item setObject:title forKey:@"title"];
        NSLog([@" end title=" stringByAppendingString:link]);
        [item setObject:link forKey:@"link"];
        
        
        [feeds addObject:[item copy]];
        
    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    //[self.tableView reloadData];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"hello reload");
    
}*/

@end
