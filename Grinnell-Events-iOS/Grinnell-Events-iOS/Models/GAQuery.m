//
//  GAQuery.m
//  Grinnell-Events-iOS
//
//  Created by MikeBook Pro on 10/14/18.
//  Copyright © 2018 Grinnell AppDev. All rights reserved.
//

#import "GAQuery.h"
#import "GAEvent.h"

@implementation GAQuery

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
    GAEvent *event = [[GAEvent alloc] init];
    event.title = @"GameDev General info session";
    event.detailDescription = @"All the game devs have a fun general meeting";
    event.location = @"CS Commons";
    event.date = @"10/14/2018";
    NSDateComponents* comps = [[NSDateComponents alloc]init];
    comps.year = 2018;
    comps.month = 10;
    comps.day = 14;
    comps.hour = 16;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* date = [calendar dateFromComponents:comps];
    event.startTime = date;
    event.endTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    event.eventid = @"123";
    NSArray *arr = [NSArray arrayWithObjects:event, event, nil];
    resultBlock(arr, nil);
}
@end
