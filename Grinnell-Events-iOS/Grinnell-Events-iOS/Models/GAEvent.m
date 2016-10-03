//
//  GAEvent.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 9/15/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "GAEvent.h"
#import <Parse/PFObject+Subclass.h>

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


+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock
{
    PFQuery *query = [GAEvent query];
    
    //Test date
    NSDate *now = [NSDate date];
    int twoDaysAgo = -2*(60*60*24);
    NSDate *pastDate = [now dateByAddingTimeInterval:twoDaysAgo];
    //Fet
   // [query whereKey:@"startTime" greaterThan:[NSDate date]];
    [query whereKey:@"startTime" greaterThanOrEqualTo:pastDate];
    [query orderByAscending:@"startTime"]; 
    query.limit = 300;
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:resultBlock];
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
