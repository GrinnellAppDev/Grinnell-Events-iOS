//
//  GAEvent.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 9/15/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "GAEvent.h"
#import "GAQuery.h"

@implementation GAEvent

@dynamic title;
@dynamic location;
@dynamic date;
@dynamic startTime;
@dynamic endTime;
@dynamic detailDescription;
@dynamic eventid;

+ (NSString *)parseClassName
{
    return @"Event2";
}


+ (void)findAllEventsInBackground:(void (^)(NSArray *, NSError *)) resultBlock
{
//    PFQuery *query = [GAEvent query];
//
//    //Test date
//    NSDate *now = [NSDate date];
//    int twoDaysAgo = -2*(60*60*24);
//    NSDate *pastDate = [now dateByAddingTimeInterval:twoDaysAgo];
//    //Fet
//   // [query whereKey:@"startTime" greaterThan:[NSDate date]];
//    [query whereKey:@"startTime" greaterThanOrEqualTo:pastDate];
//    [query orderByAscending:@"startTime"];
//    query.limit = 300;
//    query.cachePolicy = kPFCachePolicyNetworkElseCache;
//    [query findObjectsInBackgroundWithBlock:resultBlock];
    GAQuery *query = [[GAQuery alloc] init];
    [query findObjectsInBackgroundWithBlock:resultBlock];
    
//    GAEvent *event = [[GAEvent alloc] init];
//    event.title = @"GameDev General info session";
//    event.detailDescription = @"All the game devs have a fun general meeting";
//    event.location = @"CS Commons";
//    event.date = @"10/14/2018";
//    NSDateComponents* comps = [[NSDateComponents alloc]init];
//    comps.year = 2018;
//    comps.month = 10;
//    comps.day = 14;
//    comps.hour = 16;
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    NSDate* date = [calendar dateFromComponents:comps];
//    event.startTime = date;
//    event.endTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
//    event.eventid = @"123";
//    NSArray *arr = [NSArray arrayWithObjects:event, event, nil];
//    NSLog(@"%@", [NSString stringWithFormat:@"%lu", (unsigned long)arr.count]);
//    resultBlock(arr, nil);
}

/*
+ (instancetype) eventWithTitle:(NSString *)aTitle andCategory:(NSString *)aCategory andDate:(NSDate *)aDate;
{
    GAEvent *event = [[GAEvent alloc] init];
    event.title = aTitle;
    event.category = aCategory;
    event.date = aDate; 
    
    return event;
}
*/


@end
