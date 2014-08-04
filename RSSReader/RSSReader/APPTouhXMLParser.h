//
//  APPTouhXMLParser.h
//  RSSReader
//
//  Created by wan bin on 7/22/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface APPTouhXMLParser : NSObject

@property NSDate * openDate;
@property int newCount;
@property NSMutableString* title;
@property NSString* url;

- (BOOL) parser:(NSString*)url;

@end
