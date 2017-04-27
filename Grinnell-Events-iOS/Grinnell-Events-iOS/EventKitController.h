#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "GAEvent.h"

@interface EventKitController : NSObject

@property (strong, readonly) EKEventStore *eventStore;
@property (assign, readonly) BOOL eventAccess;
@property (assign, readonly) BOOL reminderAccess;


- (void) addEventToCalendar:(GAEvent*)eventToSave;

@end
