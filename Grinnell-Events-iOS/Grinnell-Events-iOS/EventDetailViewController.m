//
//  EventDetailViewController.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventKitController.h"
#import "NSDate+GADate.h"
#import "GAEvent.h"


@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *conflictLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conflictImageView;


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
    
    self.timeLabel.text =  [NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:self.theEvent.startTime], [NSDate timeStringFormatFromDate:self.theEvent.endTime]];
    
    self.dateLabel.text = self.theEvent.date;
    self.titleLabel.text = self.theEvent.title;
    self.locationLabel.text = self.theEvent.location;
    //self.descriptionLabel.text = self.theEvent.description;

}

- (void) viewWillAppear:(BOOL)animated {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self updateConflictCell];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)addEventToCalendar:(id)sender {
    
    NSArray *allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    NSPredicate *eventPredicate = [self.eventKitController.eventStore predicateForEventsWithStartDate:self.theEvent.startTime endDate:self.theEvent.endTime calendars:allCalendars];
    NSArray *matchingEvents = [self.eventKitController.eventStore eventsMatchingPredicate:eventPredicate];
    
    if (matchingEvents) {
        NSString *firstConflicting = [matchingEvents.firstObject title];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh! You have conflicts with this event!" message: [NSString stringWithFormat:@"%@ conflicts", firstConflicting]  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Anyway", nil];
        
        [alert show];
    } else {
            [self.eventKitController addEventWithName:self.theEvent.title startTime:self.theEvent.startTime endTime:self.theEvent.endTime];
    }
    

}

- (void)updateConflictCell {
    
    
    NSArray *allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    NSPredicate *eventPredicate = [self.eventKitController.eventStore predicateForEventsWithStartDate:self.theEvent.startTime endDate:self.theEvent.endTime calendars:allCalendars];
    
    
    NSArray *matches = [self.eventKitController.eventStore eventsMatchingPredicate:eventPredicate];
    NSMutableArray *matchingEvents = [NSMutableArray arrayWithArray:matches];
    
    //Remove all "all-day" events;
    for (EKEvent *event in matchingEvents) {
        if (event.allDay) {
            [matchingEvents removeObject:event];
        }
    }

    
    if (matchingEvents) {
        
        EKEvent *firstConflict = matchingEvents.firstObject;
        DLog(@"even: %@", firstConflict);
        
        NSString *title = firstConflict.title;
        
        NSString *start = [NSDate timeStringFormatFromDate:firstConflict.startDate];
        
        NSString *end = [NSDate timeStringFormatFromDate:firstConflict.endDate];
        NSString *conflictText = [NSString stringWithFormat:@"%@ (%@ - %@) conflicts with this event.", title, start, end];
       
        
        
       // DLog(@"%@", matchingEvents);
        
      //  NSString *firstConflicting = [matchingEvents.firstObject title];
        self.conflictLabel.text = conflictText;
        self.conflictImageView.image = [UIImage imageNamed:@"red_circle.jpg"];
    } else {
        self.conflictLabel.text = @"You are free for this event!";
        self.conflictImageView.image = [UIImage imageNamed:@"green_circle.jpg"];
    }
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
         [self.eventKitController addEventWithName:self.theEvent.title startTime:self.theEvent.startTime endTime:self.theEvent.endTime];
    }
}

- (IBAction)doSpecialThings:(id)sender {

}
@end
