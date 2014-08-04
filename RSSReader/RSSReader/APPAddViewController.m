//
//  APPAddViewController.m
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPAddViewController.h"

@interface APPAddViewController () {
    NSMutableArray *feeds;
    NSMutableDictionary *item;
}

@end

@implementation APPAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    item    = [[NSMutableDictionary alloc] init];
    [item setObject:@"hello 0" forKey:@"rssTitle"];
    [item setObject:@"http://www.doyj.com/rss/" forKey:@"rssUrl"];
    [feeds addObject:item];
    
    item    = [[NSMutableDictionary alloc] init];
    [item setObject:@"hello 1" forKey:@"rssTitle"];
    [item setObject:@"http://onevcat.com/rss" forKey:@"rssUrl"];
    [feeds addObject:item];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    return cell;
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"rssUrl"];
        [[segue destinationViewController] setRssUrl:string];
        string = [feeds[indexPath.row] objectForKey: @"rssTitle"];
        [[segue destinationViewController] setRssTitle:string];
        
        
    }
}
 */

@end
