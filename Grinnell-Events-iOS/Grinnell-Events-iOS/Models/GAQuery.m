//
//  GAQuery.m
//  Grinnell-Events-iOS
//
//  Created by MikeBook Pro on 10/14/18.
//  Copyright © 2018 Grinnell AppDev. All rights reserved.
//

#import "GAQuery.h"

@implementation GAQuery

@synthesize marrXMLData;
@synthesize mstrXMLString;
@synthesize mdictXMLPart;

- (id)initWithTime
{
    self = [super init];
    //Test date
    NSDate *now = [NSDate date];
    int twoDaysAgo = -2*(60*60*24);
    NSDate *pastDate = [now dateByAddingTimeInterval:twoDaysAgo];
    self->_startTime = pastDate;
    return self;
}

- (void)findObjectsInBackgroundWithBlock:(void (^)(NSArray *, NSError *))resultBlock
{
    [self startParsing];
    
    resultBlock([marrXMLData copy], nil);
}

- (void)startParsing
{
    NSURL *url = [[NSURL alloc] initWithString:@"https://25livepub.collegenet.com/calendars/web-calendar.xml"];
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [xmlparser setDelegate:self];
    
    BOOL success = [xmlparser parse];
    
    if(success){
        NSLog(@"No Errors");
    }
    else{
        NSLog(@"Error Error Error!!!");
    }
    
    NSLog(@"Heyyyyyyy I found %lu events in this database!!!", (unsigned long)marrXMLData.count);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"feed"]) {
        marrXMLData = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"entry"]) {
        mdictXMLPart = [[GAEvent alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if (!mstrXMLString) {
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [mstrXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"title"]) {
        NSString *title = [mstrXMLString copy];
        mdictXMLPart.title = title;
        NSLog(@"%@", mdictXMLPart.title);
        //mdictXMLPart.title = @"Bucksbaum";
        mdictXMLPart.eventid = @"123";
    }
    if([elementName isEqualToString:@"published"]) {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSDate *date = [dateFormat dateFromString:mstrXMLString];
        mdictXMLPart.date = [[[mstrXMLString substringToIndex:13] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"HEEEEYEYEYEYEYE LOOK %@", mdictXMLPart.date);
        mdictXMLPart.startTime = date;
        mdictXMLPart.endTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    }
    if ([elementName isEqualToString:@"content"]) {
        NSArray* contents = [mstrXMLString componentsSeparatedByString:@"<br/>"];
        mdictXMLPart.location = contents[0];
        mdictXMLPart.detailDescription = contents[2];
        
//        NSMutableString *time = contents[1];
//        NSString *start = [time componentsSeparatedByString:@"&"][0];
//        NSString *end = [time componentsSeparatedByString:@"&"][0];
//        NSLog(@"%@", start);
//
//        // Convert string to date object
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"yyyy-MM-ddThh:mm:ssZ"];
//        mdictXMLPart.startTime = [dateFormat dateFromString:start];
//        mdictXMLPart.endTime = [dateFormat dateFromString:end];
////
        NSDateComponents* comps = [[NSDateComponents alloc]init];
        comps.year = 2018;
        comps.month = 10;
        comps.day = 14;
        comps.hour = 16;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* date = [calendar dateFromComponents:comps];
        //mdictXMLPart.startTime = date;
        //mdictXMLPart.endTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    }
    if ([elementName isEqualToString:@"entry"]) {
        [marrXMLData addObject:mdictXMLPart];
    }
    mstrXMLString = nil;
}

@end
