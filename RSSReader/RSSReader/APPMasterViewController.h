//
//  APPMasterViewController.h
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPRss.h"

@interface APPMasterViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * url;
@property (nonatomic) NSInteger  idx;



@end
