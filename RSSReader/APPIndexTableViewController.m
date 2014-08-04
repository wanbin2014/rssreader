//
//  APPIndexTableViewController.m
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPIndexTableViewController.h"
#import "APPMasterViewController.h"
#import "APPAddTableViewController.h"
#import "APPRss.h"
#import "APPXMLParser.h"


@interface APPIndexTableViewController () {
    NSMutableArray *feeds;
    
    /* for xml parser */
    int flag;
    int newCount;
    NSMutableString *titleTmp;
    NSString *element;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;





@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
- (IBAction)edit:(id)sender;
//- (IBAction)already_read:(UIStoryboardSegue *)segue;

@end

@implementation APPIndexTableViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"订阅列表";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Do any additional setup after loading the view.
    feeds = [[NSMutableArray alloc] init];
    
    
    //判断表是否存在，不存在则建表。
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"rss.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        NSLog(@"datapath is not  exist");
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
        {
            char *errMsg;
           
            
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS rss (URL TEXT PRIMARY KEY , TITLE TEXT, READCOUNT INTEGER, NEWCOUNT INTEGER, OPENDATE TEXT, LASTFLUSHDATE TEXT)";
            
            
             
           //const char *sql_stmt = "DROP TABLE rss";
            
            if (sqlite3_exec(rssDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                status.text = @"Failed to create rss table";
                NSLog(@"Failed to create table");
                 NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
            } else {
                status.text = @"Success to create table";
                 NSLog(@"Success to create table");
            }
            
            sql_stmt = "CREATE TABLE IF NOT EXISTS content (TITLE TEXT,URL TEXT,RSS_URL TEXT)";
            if (sqlite3_exec(rssDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                status.text = @"Failed to create content table";
                NSLog(@"Failed to create content table");
                NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
            } else {
                status.text = @"Success to create content table";
                NSLog(@"Success to create content  table");
            }
            
            sqlite3_close(rssDB);
        } else {
            status.text = @"Failed to open/create database";
            NSLog(@"Failed to open/create database");
        }
    } else {
        NSLog(@"datapath is exist %@",databasePath);
    }
/*
    //删除数据库
    NSError * error;
    NSLog(@"datapath %@",databasePath);
    BOOL success = [filemgr removeItemAtPath:databasePath error:&error];
    if (!success) {
        NSLog(@"Error removing file at path: %@", error.localizedDescription);
    } else {
        NSLog(@"datapath remove");
    }
    return;Read rss success
    */
    
    
    
    //从表中读取数据
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
    {
        NSString *querySQL =  @"SELECT url,title,readcount,newcount,opendate,lastflushdate  FROM rss";
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(rssDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
               
                char *urlChars = (char *) sqlite3_column_text(statement, 0);
                char *titleChars = (char *) sqlite3_column_text(statement, 1);
                int readcount = sqlite3_column_int(statement, 2);
                int newcount = sqlite3_column_int(statement, 3);
 
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *openDate =[dateFormat dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
                NSDate *lastFlushDate =[dateFormat dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]];
                
                 APPRss* rss = [[APPRss alloc] init];
                [rss setUrl:[[NSString alloc] initWithUTF8String:urlChars ]];
                [rss setTitle:[[NSString alloc] initWithUTF8String:titleChars]];
                
                [rss setReadCount:readcount];
                [rss setNewCount:newcount];
                [rss setOpenDate:openDate];
                [rss setLastFlushDate:lastFlushDate];
                

                [feeds addObject:rss];
                NSLog(@"Read rss success");

            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"read rss fail");
        }
        sqlite3_close(rssDB);
    }

    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    

}

- (void)becomeActive:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"count:%u",[feeds count]);
    return feeds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RssCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RssCell"];
    }
    APPRss *item = feeds[indexPath.row];
    cell.textLabel.text = item.title;
    if(item.newCount == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"已读"];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d条更新",item.newCount];
    }

    
    NSDate * current = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSCalendarUnitHour
                                               fromDate:item.lastFlushDate
                                                 toDate:current
                                                options:0];
    NSLog(@"NSDateCompents=%@",components);
    
    if (components.hour < 1) {
    

        return cell;
    }

    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Get center of cell (vertically)
    int center = [cell frame].size.height / 2;
    
    // Size (width) of the text in the cell
   //CGSize size = [[[cell textLabel] text] sizeWithFont:[[cell textLabel] font]];
 
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
 

 
    
    int SPINNER_SIZE = 10;
    // Locate spinner in the center of the cell at end of text
//    [spinner setFrame:CGRectMake(size.width + SPINNER_SIZE, center - SPINNER_SIZE / 2, SPINNER_SIZE, SPINNER_SIZE)];
    [spinner setFrame:CGRectMake([cell frame].size.width-40-SPINNER_SIZE, center - SPINNER_SIZE / 2, SPINNER_SIZE, SPINNER_SIZE)];
    [[cell contentView] addSubview:spinner];
    
    [spinner startAnimating];
    APPXMLParser *parserDelegate = [[APPXMLParser alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:item.url];
        NSLog(@"master url:%@",url);
        NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];

        [parserDelegate setOpenDate:item.openDate];
        NSLog(@"openDate=%@",item.openDate);
        [parser setDelegate:parserDelegate];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [spinner stopAnimating];
            if (parserDelegate.newCount == 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"已读"];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d条更新",parserDelegate.newCount];
            }
            item.lastFlushDate = [NSDate date];
            
            
            //更新content表，以便后面可以直接从数据库里读最新的数据
            sqlite3_stmt    *statement;
 
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
            {
                
                NSString* deleteSQL = [NSString stringWithFormat:@"delete from content where rss_url=\'%@\'",item.url];
                NSLog(@"update sql: %@",deleteSQL);
                const char *delete_stmt = [deleteSQL UTF8String];
                sqlite3_prepare_v2(rssDB, delete_stmt,-1, &statement, NULL);
                
                
                
                if (sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"delete old content SUCCESS");
                } else {
                    NSLog(@"delete old content fail");
                }
                
                for(int i = 0; i < parserDelegate.contentTitle.count; i++) {
                    NSString *insertSQL = [NSString stringWithFormat:
                                           @"INSERT INTO content (title, url,rss_url) VALUES (\'%@\', \'%@\',\'%@\')",parserDelegate.contentTitle[i],parserDelegate.contentUrl[i],item.url];
                    const char *insert_stmt = [insertSQL UTF8String];
                    sqlite3_prepare_v2(rssDB, insert_stmt,-1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE){
                        NSLog(@"insert content SUCCESS");
                    } else {
                        NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
                        NSLog(@"insert content error");
                    }
                }
                
                
                sqlite3_finalize(statement);
                sqlite3_close(rssDB);
            }
            
            
            
        });
        
    });
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMaster"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        APPRss *item = feeds[indexPath.row];
        NSLog(@"hello 0");
        [[segue destinationViewController] setUrl:item.url];
        [[segue destinationViewController] setTitle:item.title];
        NSLog(@"hello 1");
        [[segue destinationViewController] setIdx:indexPath.row];

    }
}



- (IBAction)already_read:(UIStoryboardSegue *)segue
{
    NSLog(@"go back......");
    APPMasterViewController *source =[segue sourceViewController];
    int idx = source.idx;
    [feeds[idx] setNewCount:0];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}


- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    APPAddTableViewController *source = [segue sourceViewController];
    
    NSURL *url = [NSURL URLWithString:source.addUrl];
    if(url == nil) {
        return;
    }
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    int SPINNER_SIZE = 10;
    // Locate spinner in the center of the cell at end of text
    [self.indicator setFrame:CGRectMake((self.view.frame.size.width - SPINNER_SIZE) / 2,(self.view.frame.size.height-SPINNER_SIZE)/2, SPINNER_SIZE, SPINNER_SIZE)];
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
    NSLog(@"indicator startAnimating...");
    
    APPXMLParser *parserDelegate = [[APPXMLParser alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* startDate = [dateFormat dateFromString:@"2000-01-01 00:00:00"];
    NSLog(@"startDate=%@",startDate);
    [parserDelegate setOpenDate:startDate];
    NSString* dateString  = @"2000-01-01 00:00:00";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSLog(@"master url:%@",url);
        NSString *urlContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[urlContents dataUsingEncoding:NSUTF8StringEncoding]];
        
        [parser setDelegate:parserDelegate];
        [parser setShouldResolveExternalEntities:NO];
        BOOL ok = [parser parse];
        
        if (ok == NO) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复制该url" , nil];
            alertView.title = @"无法获取RSS源";
            alertView.message = [NSString stringWithFormat:@"请检查以下RSS源的url是否正确?\n%@",url];
            NSLog(@"ERROR:%@",[parser parserError ]);
           // [alertView show];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            [self.indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
            if (source.addUrl != nil) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = source.addUrl;
            }

            return;
        }
        
        NSLog(@"paser ok");

        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"hello stop...");
            [self.indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
            APPRss * item = [[APPRss alloc] init];
            item.url = source.addUrl;
            item.title = parserDelegate.title;
            item.openDate = startDate;
            item.lastFlushDate = [NSDate date];
            
            
            
            NSString * lastFlushDateStr = [dateFormat stringFromDate:item.lastFlushDate];
            
            
            if ([item.title isEqualToString:@""]) {
                item.title = item.url;
            }
            item.newCount = parserDelegate.newCount;
            NSLog(@"add blog new_count=%d",item.newCount);
            
            [feeds addObject:item];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            //把新增的RSS源保存到数据库里
            sqlite3_stmt    *statement;
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
            {
                

                item.title = [item.title stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                NSString *insertSQL = [NSString stringWithFormat:
                                       @"INSERT INTO rss (title, url,readcount,newcount,opendate,lastflushdate) VALUES (\'%@\', \'%@\', 0,%d,\'%@\',\'%@\')",item.title,item.url,item.newCount, dateString,lastFlushDateStr];
                NSLog(@"insert sql %@",insertSQL);
 
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(rssDB, insert_stmt,-1, &statement, NULL);
                


                
                
                if (sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"ADD SUCCESS");
                } else {
                    NSString* errMsg = [NSString stringWithUTF8String:sqlite3_errmsg(rssDB)];
                    if ([errMsg isEqualToString:@"column URL is not unique"]) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定" , nil];
                        alertView.title = @"错误";
                        alertView.message = [NSString stringWithFormat:@"该RSS源已经存在，不必重复添加\n%@",url];
                        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                        
                    }
                    NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
                }
                sqlite3_finalize(statement);
                sqlite3_close(rssDB);
            }
            
            
            //更新content表，以便后面可以直接从数据库里读最新的数据

            
            if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
            {
                
                NSString* deleteSQL = [NSString stringWithFormat:@"delete from content where rss_url=\'%@\'",item.url];
                NSLog(@"update sql: %@",deleteSQL);
                const char *delete_stmt = [deleteSQL UTF8String];
                sqlite3_prepare_v2(rssDB, delete_stmt,-1, &statement, NULL);
                
                
                
                if (sqlite3_step(statement) == SQLITE_DONE){
                    NSLog(@"delete old content SUCCESS");
                } else {
                    NSLog(@"delete old content fail");
                }
                
                for(int i = 0; i < parserDelegate.contentTitle.count; i++) {
                    
                    parserDelegate.title = [parserDelegate.title stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                    NSString *insertSQL = [NSString stringWithFormat:
                                           @"INSERT INTO content (title, url,rss_url) VALUES (\'%@\', \'%@\', \'%@\')",parserDelegate.contentTitle[i],parserDelegate.contentUrl[i],item.url];
                    const char *insert_stmt = [insertSQL UTF8String];
                    sqlite3_prepare_v2(rssDB, insert_stmt,-1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE){
                        NSLog(@"insert content SUCCESS");
                    } else {
                        NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
                        NSLog(@"insert content error");
                    }
                }
                
                
                sqlite3_finalize(statement);
                sqlite3_close(rssDB);
            }

        });
        
    });



    
}

- (IBAction)edit:(id)sender {
    if(sender == self.editButton && [[sender titleLabel].text isEqualToString:@"完成"]) {
        
        [self.tableView setEditing:NO animated:NO ];
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        return;
    }
    if(sender == self.editButton) {
        [self.tableView setEditing:YES animated:YES];
        [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSLog(@"xxxx%u",indexPath.row );
    

    
    
    //把RSS的数据从数据库里删除。
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &rssDB) == SQLITE_OK)
    {
        
        
        
        
        APPRss *item = feeds[indexPath.row];
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from rss where url=\'%@\'", item.url ];
        
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(rssDB, delete_stmt,-1, &statement, NULL);
        
        
        
        
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Delete SUCCESS");
        } else {


            NSLog(@"error: %s\n",sqlite3_errmsg(rssDB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDB);
    }
    
        [feeds removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set NSString for button display text here.
    NSString *newTitle = @"删除";
    return newTitle;
    
}



@end
