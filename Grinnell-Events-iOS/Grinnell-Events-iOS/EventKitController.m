    //
    //  EventKitController.m
    //  Grinnell-Events-iOS
    //
    //  Created by Maijid Moujaled on 10/2/13.
    //  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
    //

    #import "EventKitController.h"

    @implementation EventKitController


    - (id)init
    {
    self = [super init];
    if (self) {
    _eventStore = [[EKEventStore alloc] init];
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            _eventAccess = YES;
            NSLog(@"YAY! Event access ON");
        } else {
            NSLog(@"Event access not granted: %@", error);
        }
    }];

    }
    return self;
    }

- (void) addEventWithName:(NSString*) eventName startTime:(NSDate*) startDate endTime:(NSDate*) endDate {

    NSLog(@"Adding event");

    if (!_eventAccess) {
        NSLog(@"No event acccess!");
        return;
    }

    //1. Create an Event
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = eventName;

    //3. Set the start and end date
    event.startDate = startDate;
    event.endDate = endDate;

    //4. Set an alarm (This is optional)
    //EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-1800]; [event addAlarm:alarm];

    //5. Add a note (This is optional)
    event.notes = @"This will be exciting!!";
    //6. Specify the calendar to store the event

    event.calendar = self.eventStore.defaultCalendarForNewEvents;
    NSLog(@"EventCal: %@", event.calendar);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *specifiedCal = [defaults objectForKey:@"selectedCal"];

    NSArray *allCalendars = [self.eventStore calendarsForEntityType: EKEntityTypeEvent];

    for (EKCalendar *cal in allCalendars) {
        if ([specifiedCal isEqualToString:cal.title] && cal.allowsContentModifications) {
            event.calendar = cal;
        }
    }
    //    NSLog(@"Adding event");
    //    
    //    if (!_eventAccess) {
    //        NSLog(@"No event acccess!");
    //        return;
    //    }
    //    
    //    //1. Create an Event
    //    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    //    event.title = eventName;
    //    
    //    //3. Set the start and end date
    //    event.startDate = startDate;
    //    event.endDate = endDate;
    //    
    //    //4. Set an alarm (This is optional)
    //    //EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-1800]; [event addAlarm:alarm];
    //    
    //    //5. Add a note (This is optional)
    //    event.notes = @"This will be exciting!!";
    //    //6. Specify the calendar to store the event
    //    
    //    event.calendar = self.eventStore.defaultCalendarForNewEvents;
    //    NSLog(@"EventCal: %@", event.calendar);
    //    
    //    
    //    NSArray *allCalendars = [self.eventStore calendarsForEntityType: EKEntityTypeEvent];
    //    
    //    NSMutableArray * writableCalendars = [NSMutableArray array];
    //    for (EKCalendar * calendar in allCalendars) {
    //        if (calendar.allowsContentModifications && [calendar.title isEqualToString:@"maijid@gmail.com"]) {
    //            //event.calendar = calendar;
    //            [writableCalendars addObject:calendar];
    //        }
    //    }
    //    NSLog(@"WC: %@", writableCalendars);
    //    
    NSError *err;
    BOOL success = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];

    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shucks!" message:@"Error occured" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    } else {
        NSString *calendarName = event.calendar.title;
        NSString *alertTitle =  [NSString stringWithFormat:@"Event added to your %@ calendar succesfully!", calendarName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:@"yay!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }

}

@end
