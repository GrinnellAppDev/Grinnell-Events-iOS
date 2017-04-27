#import <Foundation/Foundation.h>

@interface NSDate (GADate)

+(NSDate *)dateWithoutTimeFromDate:(NSDate *)date;

+(NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)formattedStringFromDate:(NSDate *)date;
+ (NSString *)timeStringFormatFromDate:(NSDate *)date;

@end
