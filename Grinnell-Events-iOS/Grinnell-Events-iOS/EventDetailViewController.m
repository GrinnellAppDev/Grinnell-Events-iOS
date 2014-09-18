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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
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
    if (self.theEvent.detailDescription) {
        self.descriptionTextView.text = self.theEvent.detailDescription;
    }
    else {
        self.descriptionTextView.text = @"Sorry. No details were given for this event :(";
    }

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
            [self.eventKitController addEventToCalendar:self.theEvent];
    }
    
    [self updateConflictCell];

}

- (void)updateConflictCell {
    
    
    NSArray *allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    NSPredicate *eventPredicate = [self.eventKitController.eventStore predicateForEventsWithStartDate:self.theEvent.startTime endDate:self.theEvent.endTime calendars:allCalendars];
    
    
    NSArray *matches = [self.eventKitController.eventStore eventsMatchingPredicate:eventPredicate];
    NSMutableArray *matchingEvents = [NSMutableArray arrayWithArray:matches];
    
    DLog(@"m: %@", matchingEvents);
    DLog(@"m: %lu", (unsigned long)matchingEvents.count);

    
    //Remove all "all-day" events;
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (EKEvent *event in matchingEvents) {
        if (event.allDay) {
            [tmpArray addObject:event];
//            [matchingEvents removeObject:event];
        }
    }
    [matchingEvents removeObjectsInArray:tmpArray];
    
    DLog(@"me: %@", matchingEvents);

    

    
    if (matchingEvents.count > 0 ) {
        
        EKEvent *firstConflict = matchingEvents.firstObject;
        DLog(@"even: %@", firstConflict);
        
        NSString *title = firstConflict.title;
        
        
        
        NSString *start = [NSDate timeStringFormatFromDate:firstConflict.startDate];
        
        NSString *end = [NSDate timeStringFormatFromDate:firstConflict.endDate];
        NSString *conflictText = [NSString stringWithFormat:@"%@ (%@ - %@) conflicts with this event.", title, start, end];
       
        
       // DLog(@"%@", matchingEvents);
        
      //  NSString *firstConflicting = [matchingEvents.firstObject title];
        if ([title isEqualToString:self.theEvent.title]) {
            self.conflictLabel.text = @"Looks like you're going to this already!";
            self.conflictImageView.image = [UIImage imageNamed:@"checkmark"];
        } else {
        self.conflictLabel.text = conflictText;
        self.conflictImageView.image = [UIImage imageNamed:@"unavailable"];
        }
    } else {
        self.conflictLabel.text = @"You are free for this event!";
        self.conflictImageView.image = [UIImage imageNamed:@"checkmark"];
    }
    
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
         [self.eventKitController addEventToCalendar:self.theEvent];
    }
}

- (IBAction)doSpecialThings:(id)sender {

}

#pragma mark - Table View Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1) {
        
        float height = [self findHeightForText:self.theEvent.detailDescription havingWidth:300.0 andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
        
        NSLog(@"HEIGHT: %f and STRING: %@", height, self.theEvent.detailDescription);
        
        if (height > 120) {
            return 120;
        }
        else {
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }

    }else {
        // return height from the storyboard
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
}

- (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize+4;
    CGFloat width = widthValue;
    if (text) {
        CGSize textSize = { width, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            //iOS 7
            CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:font}
                                              context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height+1);
        }
        else
        {
            //iOS 6.0
            size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        }
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

@end
