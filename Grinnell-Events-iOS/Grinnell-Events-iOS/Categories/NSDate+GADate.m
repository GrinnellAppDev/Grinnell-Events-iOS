//
//  NSDate+GADate.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "NSDate+GADate.h"

@implementation NSDate (GADate)

+(NSDate *)dateWithoutTimeFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate:date];
    return [calendar dateFromComponents:components];
}

+(NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MM dd yyyy"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
// "Fri Oct 04 2013"
}


+ (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
   
    return dateString;
}

+ (NSString *)timeStringFormatFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormat stringFromDate:date];
    return timeString;
}

@end
