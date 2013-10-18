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

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+ (NSString *)parseClassName
{
    return @"Event";
}


+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock
{
    PFQuery *query = [GAEvent query];
    
    //Fet
    [query whereKey:@"startTime" greaterThan:[NSDate date]];
    [query orderByAscending:@"startTime"]; 
    query.limit = 300;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        resultBlock(events, error);
    }];
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
