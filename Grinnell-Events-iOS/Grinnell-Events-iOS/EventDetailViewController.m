#import "EventDetailViewController.h"
#import "EventKitController.h"
#import "GAEvent.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *conflictLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conflictImageView;


@property (nonatomic, strong) EventKitController *eventKitController;

@end

@implementation EventDetailViewController {
  NSDateFormatter *_dateFormatter;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.title = self.theEvent.title;
  self.eventKitController = [[EventKitController alloc] init];
  
  
  NSDateIntervalFormatter* formatter = [[NSDateIntervalFormatter alloc] init];
  formatter.dateStyle = NSDateIntervalFormatterShortStyle;
  formatter.timeStyle = NSDateIntervalFormatterNoStyle;
  self.timeLabel.text = [formatter stringFromDate:_theEvent.startTime toDate:_theEvent.endTime];
  
  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setTimeStyle:NSDateFormatterLongStyle];
  [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
  self.dateLabel.text = [_dateFormatter stringFromDate:_theEvent.startTime];
  
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
  
  //Remove all "all-day" events;
  NSMutableArray *tmpArray = [NSMutableArray new];
  for (EKEvent *event in matchingEvents) {
    if (event.allDay) {
      [tmpArray addObject:event];
      //            [matchingEvents removeObject:event];
    }
  }
  [matchingEvents removeObjectsInArray:tmpArray];
  
  if (matchingEvents.count > 0 ) {
    
    EKEvent *firstConflict = matchingEvents.firstObject;
    
    NSString *title = firstConflict.title;
    
    NSDateIntervalFormatter* formatter = [[NSDateIntervalFormatter alloc] init];
    formatter.dateStyle = NSDateIntervalFormatterNoStyle;
    formatter.timeStyle = NSDateIntervalFormatterShortStyle;
    
    NSString *conflictText = [NSString stringWithFormat:@"%@ (%@) conflicts with this event.", title, [formatter stringFromDate:firstConflict.startDate toDate:firstConflict.endDate]];
    
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

#pragma mark - Table View Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.section == 1) {
    float height = 100;
    // float height = [self findHeightForText:self.theEvent.detailDescription havingWidth:300.0 andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
    
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
  if (text) {
    CGSize size;
    //iOS 7
    CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    size = CGSizeMake(frame.size.width, frame.size.height+1);
  }
  return result;
}

@end
