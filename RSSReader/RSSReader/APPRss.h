//
//  APPRss.h
//  RSSReader
//
//  Created by wan bin on 7/19/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPRss : NSObject

@property (copy,nonatomic) NSString * title;
@property   (copy,nonatomic)NSString * url;
@property int newCount;
@property int readCount;
@property (copy,nonatomic) NSDate * openDate;
@property (copy,nonatomic) NSDate * lastFlushDate;


@end
