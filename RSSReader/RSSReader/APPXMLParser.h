//
//  APPXMLParser.h
//  RSSReader
//
//  Created by wan bin on 7/21/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPXMLParser : NSObject <NSXMLParserDelegate>
@property NSDate * openDate;
@property int newCount;
@property NSMutableString* title;

@property NSMutableArray* contentTitle;
@property NSMutableArray* contentUrl;

@end
