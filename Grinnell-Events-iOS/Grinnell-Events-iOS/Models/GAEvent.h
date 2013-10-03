//
//  GAEvent.h
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 9/15/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GAEvent : PFObject <PFSubclassing>



@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailDescription;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *eventid;

//+ (instancetype) eventWithTitle:(NSString *)aTitle andCategory:(NSString *)aCategory andDate:(NSDate *)aDate;


+ (NSString *)parseClassName;
+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock;

@end
