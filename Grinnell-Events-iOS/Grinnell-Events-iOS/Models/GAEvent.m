#import "GAEvent.h"
#import <Parse/PFObject+Subclass.h>

@implementation GAEvent

@dynamic title;
@dynamic location;
@dynamic startTime;
@dynamic endTime;
@dynamic detailDescription;
@dynamic eventid;


+ (NSString *)parseClassName
{
    return @"Event";
}


+ (void)findAllEventsInBackground:(PFArrayResultBlock)resultBlock
{
    PFQuery *query = [GAEvent query];
    
    //Test date
    NSDate *now = [NSDate date];
    int twoDaysAgo = -2*(60*60*24);
    NSDate *pastDate = [now dateByAddingTimeInterval:twoDaysAgo];
    [query whereKey:@"startTime" greaterThanOrEqualTo:pastDate];
    [query orderByAscending:@"startTime"]; 
    query.limit = 300;
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:resultBlock];
}

@end
