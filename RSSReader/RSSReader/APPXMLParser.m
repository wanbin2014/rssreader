//
//  APPXMLParser.m
//  RSSReader
//
//  Created by wan bin on 7/21/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPXMLParser.h"

@interface APPXMLParser(){
    int flag;

    NSString* element;
    NSDateFormatter *fmt;
    BOOL isAtom;
    bool isBody;
    
    NSMutableString* title_tmp;
    NSMutableString* url_tmp;
    
}@end



@implementation APPXMLParser
@synthesize  newCount,openDate;

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    flag =0;
    newCount =0;
    _title = [[NSMutableString alloc] init];
    self.contentTitle = [[NSMutableArray alloc] init];
    self.contentUrl = [[NSMutableArray alloc] init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
     NSLog(@"didEndDocument title=%@", _title);
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    if ([element isEqualToString:@"feed"]) {
        NSString *value = [attributeDict objectForKey:@"xmlns"];
        if ([value isEqualToString:@"http://www.w3.org/2005/Atom"]) {
            isAtom = YES;
        }
    }
    if(isAtom == YES && [element isEqualToString:@"entry"]) {
        isBody = YES;
        title_tmp = [[NSMutableString alloc]init];
        url_tmp = [[NSMutableString alloc] init];
        
    } else if([element isEqualToString:@"item"]) {
        isBody = YES;
        
        title_tmp = [[NSMutableString alloc]init];
        url_tmp = [[NSMutableString alloc] init];
    }
    
    if(![elementName isEqual:@"link"])
        return;
    
    // then you just need to grab each of your attributes
    NSString* href = [attributeDict objectForKey:@"href"];
    if(href != nil) {
        [ url_tmp appendString:href];
        NSLog(@"url=%@",url_tmp);
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"] && isBody == NO) { //只取第一条TITLE
        NSLog(@"parser web site title");
        [_title appendString:string];
    }
    
    if (isBody == YES) {
        if (isAtom == YES && [element isEqualToString:@"updated"]) {//atom 1.0
            if (fmt == nil) {
                fmt = [[NSDateFormatter alloc] init];
                [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            }
            NSString* tmp = [[string stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            NSDate *pubDate = [fmt dateFromString:tmp];
            //NSLog([NSString stringWithFormat:@"updated:%@",pubDate]);
            if (pubDate == nil && [string length] > 10) {
                [fmt setDateFormat:@"yyyy-MM-dd"];
                NSRange range = NSMakeRange(0, 10);
                 pubDate = [fmt dateFromString:[string substringWithRange:range]];
                 NSLog(@"pubDate=%@",pubDate);
                if (pubDate == nil) {
                    return;
                }
            }
            
            if ([pubDate compare:openDate] == NSOrderedDescending) {
                //NSLog(@"update!!!");
                newCount++;
            }
            
        } else if ([element isEqualToString:@"pubDate"]) { //RSS 2.0
            if (fmt == nil) {
                fmt = [[NSDateFormatter alloc] init];
                [fmt setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];
                [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            }
            NSDate *pubDate = [fmt dateFromString:string];
           // NSLog([NSString stringWithFormat:@"pubDate:%@",pubDate]);
            if (pubDate == nil && [string length] > 10) {
                [fmt setDateFormat:@"yyyy-MM-dd"];
                NSRange range = NSMakeRange(0, 10);
                pubDate = [fmt dateFromString:[string substringWithRange:range]];
                NSLog(@"pubDate=%@",pubDate);
                if (pubDate == nil) {
                    return;
                }
            }
            if ([pubDate compare:openDate] == NSOrderedDescending) {
                NSLog(@"hello pubDate=%@,openDate=%@",pubDate,openDate);
                newCount++;
            }
        }
        
        if ([element isEqualToString:@"title"]) {
            NSLog(@"title=%@", string);
            [title_tmp appendString:string];
        } else if ([element isEqualToString:@"link"]) {
            NSCharacterSet * erase = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString * url = [string stringByTrimmingCharactersInSet:erase];
            if (![[ url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] isEqualToString:url]){
                [ url_tmp appendString:url];
            } else {
                [ url_tmp appendString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            
            
        }
    }

    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        NSLog(@" end title=%@",title_tmp);
        [self.contentTitle addObject:title_tmp];
        NSLog(@" end URL qulifiedName=%@",qName);
        [self.contentUrl addObject:url_tmp];
    }
    

}

@end
