//
//  APPDetailViewController.m
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPDetailViewController.h"

@interface APPDetailViewController () {

    UIActivityIndicatorView *  indicator;
}

- (void)configureView;
@end

@implementation APPDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    

/*
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
 */
    
    self.title = @"详情";
    /*
    NSURL *myURL = [NSURL URLWithString: [[self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     */
    NSURL *myURL = [NSURL URLWithString: self.url ];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    



    
    NSLog(@"detail:%@",self.url);
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    int SPINNER_SIZE = 10;
    // Locate spinner in the center of the cell at end of text
    [indicator setFrame:CGRectMake((self.view.frame.size.width - SPINNER_SIZE) / 2,(self.view.frame.size.height-SPINNER_SIZE)/2, SPINNER_SIZE, SPINNER_SIZE)];
    [self.view addSubview:indicator];
    [indicator startAnimating];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [indicator stopAnimating];
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
}
/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
}
*/





@end
