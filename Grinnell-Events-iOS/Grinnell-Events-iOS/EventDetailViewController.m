//
//  EventDetailViewController.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventKitController.h"
#import "GAEvent.h"


@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, readonly) EKEventStore *eventStore;
@property (assign, readonly) BOOL eventAccess;
@property (assign, readonly) BOOL reminderAccess;

@property (nonatomic, strong) EventKitController *eventKitController;

@end

@implementation EventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"EK allocated");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.eventKitController = [[EventKitController alloc] init];
    
    
    NSArray * allCalendars = [_eventStore calendarsForEntityType:EKEntityMaskEvent |
                              EKEntityMaskReminder];
    NSMutableArray * writableCalendars = [NSMutableArray array];
    for (EKCalendar * calendar in allCalendars) {
        
        if (calendar.allowsContentModifications) {
            [writableCalendars addObject:calendar];
        }
    }
    
    EKCalendar *calendar = self.eventStore.defaultCalendarForNewEvents;
    
    NSLog(@"calendar: %@", calendar);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)addEventToCalendar:(id)sender {
    [self.eventKitController addEventWithName:self.theEvent.title startTime:self.theEvent.startTime endTime:self.theEvent.endTime];
}

@end
