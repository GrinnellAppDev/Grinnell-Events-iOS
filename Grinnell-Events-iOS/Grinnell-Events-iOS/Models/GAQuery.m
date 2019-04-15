//
//  GAQuery.m
//  Grinnell-Events-iOS
//
//  Created by MikeBook Pro on 10/14/18.
//  Copyright © 2018 Grinnell AppDev. All rights reserved.
//

#import "GAQuery.h"
#import "GTMNSString+HTML.h"
@implementation GAQuery
@synthesize marrXMLData;
@synthesize mstrXMLString;
@synthesize mdictXMLPart;

- (void) extractAMPM: (NSString*) originalString withAMPMString: (NSString**) AMPM withHourString: (NSString**) hour withMinutesString: (NSString**) minutes{
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *ampmSet = [NSCharacterSet characterSetWithCharactersInString: @":ampm"];
    
    //Take hour
    
    [scanner scanUpToCharactersFromSet:ampmSet intoString: hour];
    //Throw away colon
    [scanner scanString:@":" intoString:NULL];
    
    //Take minutes
    [scanner scanUpToCharactersFromSet:ampmSet intoString: minutes];
    
    //Collect am/pm characters
    
    [scanner scanCharactersFromSet:ampmSet intoString: AMPM];
    
}

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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"feed"]) {
        marrXMLData = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"entry"]) {
        mdictXMLPart = [[GAEvent alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!mstrXMLString) {
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [mstrXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"title"]) {
        NSString *title = [mstrXMLString copy];
        mdictXMLPart.title = title;
        NSLog(@"Title: %@", mdictXMLPart.title);
        //mdictXMLPart.title = @"Bucksbaum";
        mdictXMLPart.eventid = @"123";
    }
    
    if([elementName isEqualToString:@"published"]) {
        //Convert start time to date
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [timeFormat setDateFormat: @"yyyy/MM/dd'T'HH:mm:ssZ"];
        //Convert back into local time
        NSDateFormatter *timeLocal = [[NSDateFormatter alloc] init];
        [timeLocal setTimeZone:[NSTimeZone timeZoneWithName:@"CDT"]];
        [timeLocal setDateFormat:@"yyyy/MM/dd"];
        //Get publish time and convert to UTC time before converting back to Grinnell time in NSString
        NSString* date = [[[mstrXMLString substringToIndex:23] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDate *curDate = [timeFormat dateFromString:date];
        mdictXMLPart.date = [timeLocal stringFromDate:curDate];
        NSLog(@"The date is %@!!!!!!%@", mdictXMLPart.date, date);
    }
    
    
    if ([elementName isEqualToString:@"content"]) {
        NSArray* contents = [mstrXMLString componentsSeparatedByString:@"<br/>"];
        
        //Check if location was present on xml file by seeing how many commas the line has
        
        //NSArray* locationArr = [contents[0] componentsSeparatedByString:@","];
        int dateIndex;
        
        if([contents[1] isEqualToString: @""]){
            mdictXMLPart.location = @"None";
            NSLog(@"Location: %@", mdictXMLPart.location);
            dateIndex=0;
        }
        
        else{
            
            mdictXMLPart.location = contents[0];
            NSLog(@"Location: %@", mdictXMLPart.location);
            dateIndex = 1;
        }
        
        //Extracting portion of xml with date and time
        NSArray* dateTime = [contents[dateIndex] componentsSeparatedByString:@","];
        
        //If event spans more than one day:
        if ([dateTime count] > 4){
            /*NSLog(@"Not written yet.");
             mdictXMLPart.startTime = 0;
             mdictXMLPart.endTime = 0;
             mdictXMLPart.detailDescription = @"none";
             mdictXMLPart.date = @"11/11/11";
             */
        }
        else{
            //Extracting time from event
            NSArray* time = [dateTime[3] componentsSeparatedByString: @"&"];
            
            
            //Start time comes before the first '&'
            //mdictXMLPart.startTime = time[0];
            NSString *startTime = time[0];
            NSLog(@"Start Time: %@", startTime);
            
            NSString *startAMPMString;
            NSString *startTimeHour;
            NSString *startTimeMinutes;
            
            //Break up the start time into parts
            [self extractAMPM:startTime withAMPMString:&startAMPMString withHourString:&startTimeHour withMinutesString:&startTimeMinutes];
            //End time comes after the last ';'
            
            //Break up the end time into parts
            NSString *endAMPMString;
            NSString *endTimeHour;
            NSString *endTimeMinutes;
            //There may not be an end time.
            if ([time count] > 1) {
                NSArray* endTimeArray = [time[3] componentsSeparatedByString: @";"];
                NSString *endTime = endTimeArray[1];
                NSLog(@"End Time: %@", endTime);
                
                [self extractAMPM:endTime withAMPMString:&endAMPMString withHourString:&endTimeHour withMinutesString:&endTimeMinutes];
                //Format start time:
                //Append minutes to start time
            } else {
                [self extractAMPM:startTime withAMPMString:&endAMPMString withHourString:&endTimeHour withMinutesString:&endTimeMinutes];
            }
            
            
            NSString *finalStartTime = @"";
            
            if (startTimeHour.length == 1){
                finalStartTime = [finalStartTime stringByAppendingString: @"0"];
            }
            finalStartTime =[finalStartTime stringByAppendingString: startTimeHour];
            finalStartTime = [finalStartTime stringByAppendingString: @":"];
            
            if (startTimeMinutes == NULL){
                finalStartTime = [finalStartTime stringByAppendingString: @"00"];
            } else{
                finalStartTime = [finalStartTime stringByAppendingString: startTimeMinutes];
            }
            
            //Append am/pm to start time
            if (startAMPMString == NULL){
                //If start time didn't have am/pm, use the end time one
                finalStartTime = [finalStartTime stringByAppendingString: endAMPMString];
            } else{
                finalStartTime = [finalStartTime stringByAppendingString: startAMPMString];
            }
            
            NSLog(@"Formatted start time: %@", finalStartTime);
            
            //Format endtime:
            //Append minutes to start time
            NSString *finalEndTime = [endTimeHour stringByAppendingString: @":"];
            if (endTimeMinutes == NULL){
                finalEndTime = [finalEndTime stringByAppendingString: @"00"];
            } else{
                finalEndTime = [finalEndTime stringByAppendingString: endTimeMinutes];
            }
            
            //Append am/pm to start time
            finalEndTime = [finalEndTime stringByAppendingString: endAMPMString];
            
            NSLog(@"Formatted end time: %@", finalEndTime);
            
            //Convert start time to date
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            
            //Date format of string we already have
            [timeFormat setDateFormat:@"hh:mma"];
            
            NSDate *startTimeDate = [timeFormat dateFromString:finalStartTime];
            
            mdictXMLPart.startTime = startTimeDate;
            
            //Convert end time to date
            NSDate *endTimeDate = [timeFormat dateFromString: finalEndTime];
            mdictXMLPart.endTime = endTimeDate;
            mdictXMLPart.detailDescription = contents[dateIndex+2];
            NSString *original = mdictXMLPart.detailDescription;
            //NSString *pattern2 = @"<.*?>";
            NSString *new = [original gtm_stringByUnescapingFromHTML];
            NSLog(@"new: %@", new);
            NSLog(@"Description: %@", mdictXMLPart.detailDescription);
            
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
        }
        NSDateComponents* comps = [[NSDateComponents alloc]init];
        comps.year = 2018;
        comps.month = 10;
        comps.day = 14;
        comps.hour = 16;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        //NSDate *date2 = [calendar dateFromComponents:comps];
        //mdictXMLPart.startTime = date;
        //mdictXMLPart.endTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    }
    if ([elementName isEqualToString:@"entry"]) {
        [marrXMLData addObject:mdictXMLPart];
    }
    mstrXMLString = nil;
}

@end

