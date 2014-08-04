//
//  APPTouhXMLParser.m
//  RSSReader
//
//  Created by wan bin on 7/22/14.
//  Copyright (c) 2014 wan bin. All rights reserved.
//

#import "APPTouhXMLParser.h"

@implementation APPTouhXMLParser

- (BOOL) parser:(NSString*) blog
{
    // Initialize the blogEntries MutableArray that we declared in the header
//    blogEntries = [[NSMutableArray alloc] init];
    
    // Convert the supplied URL string  a usable URL object
    NSURL *url = [NSURL URLWithString: blog];
    
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];
    
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
    
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//item" error:nil];
    
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
        
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in blogEntries
        NSMutableDictionary *blogItem = [[NSMutableDictionary alloc] init];
        
        // Create a counter variable as type "int"
        int counter;
        
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
            
            // Add each field to the blogItem Dictionary with the node name as key and node value as the value
            NSString* property =[[resultElement childAtIndex:counter] name];
            if ([property isEqualToString:@"title"] || [property isEqualToString:@"pubDate"] || [property isEqualToString:@"updated"]) {
                [blogItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
            }

        }
        
        // Add the blogItem to the global blogEntries Array so that the view can access it.
        [blogEntries addObject:[blogItem copy]];
    }
    
    

}

@end
