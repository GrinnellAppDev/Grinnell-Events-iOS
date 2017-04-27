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

+ (NSString *)parseClassName;
+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock;

@end
