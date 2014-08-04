//
//  APPDetailViewController.h
//  RSSReader
//
//  Created by wan bin on 7/18/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPDetailViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
