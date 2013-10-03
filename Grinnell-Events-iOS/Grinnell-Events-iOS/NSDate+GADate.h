//
//  NSDate+GADate.h
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GADate)

+(NSDate *)dateWithoutTimeFromDate:(NSDate *)date;

+(NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)formattedStringFromDate:(NSDate *)date;
+ (NSString *)timeStringFormatFromDate:(NSDate *)date;

@end
