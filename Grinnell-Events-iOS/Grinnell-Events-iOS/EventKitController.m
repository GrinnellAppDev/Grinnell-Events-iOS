#import "EventKitController.h"

@implementation EventKitController

- (id)init
{
    if (self = [super init]) {
        _eventStore = [[EKEventStore alloc] init];
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
          _eventAccess = granted;
        }];
        
    }
    return self;
}

- (void) addEventToCalendar:(GAEvent*)eventToSave{
    if (!_eventAccess) {
        NSLog(@"No event acccess!");
        return;
    }
    
    // Create an Event
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = eventToSave.title;
    
    // Set the start and end date
    event.startDate = eventToSave.startTime;
    event.endDate =  eventToSave.endTime;
    
    // Add details
    event.notes = eventToSave.detailDescription;
    event.location = eventToSave.location;
    
    event.calendar = self.eventStore.defaultCalendarForNewEvents;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *specifiedCalString = [defaults objectForKey:@"selectedCal"];
    
    NSArray *allCalendars = [self.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    for (EKCalendar *cal in allCalendars) {
        if ([specifiedCalString isEqualToString:cal.title] && cal.allowsContentModifications) {
            event.calendar = cal;
        }
    }
    
    NSError *err;
    
    BOOL success = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shucks!" message:@"Error occured" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    } else {
        NSString *calendarName = event.calendar.title;
        NSString *alertTitle =  [NSString stringWithFormat:@"Event added to your %@ calendar succesfully!", calendarName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
}

@end
