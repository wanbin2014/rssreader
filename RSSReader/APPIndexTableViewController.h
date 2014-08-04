//
//  APPIndexTableViewController.h
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"
#import "APPRss.h"

@interface APPIndexTableViewController : UITableViewController {
    sqlite3* rssDB;
    NSString        *databasePath;
    UILabel *status;
}

//@property (strong, nonatomic) IBOutlet UILabel *status;
@property (copy,nonatomic) NSString * title;
- (IBAction)already_read:(UIStoryboardSegue *)segue;


@end
