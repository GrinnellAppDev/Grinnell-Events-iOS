#import "ViewController.h"
#import "GAEvent.h"
#import "GAEventCell.h"
#import "EventDetailViewController.h"

#import <Parse/Parse.h>


@interface ViewController () <MZDayPickerDelegate, MZDayPickerDataSource>

- (IBAction)goToToday:(id)sender;

@end

@implementation ViewController {
  NSMutableDictionary<NSDate*,NSMutableArray<GAEvent *> *> *_events;
  NSArray<NSDate*> *_sortedDays;
  NSDate *_displayedDate;
  NSDateFormatter *_dateFormatter;
}

- (void)setEvents:(NSArray<GAEvent *>*)events {
  _events = [NSMutableDictionary dictionary];
  for (GAEvent *event in events) {
    NSDate *dateKey = [[self class] dateAtBeginningOfDayForDate:event.startTime];
    if (!_events[dateKey]) {
      _events[dateKey] = [NSMutableArray arrayWithObject:event];
    } else {
      [_events[dateKey] addObject:event];
    }
  }
  _sortedDays = [[_events allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (IBAction)didDoubleTapDays:(id)sender {
  [self goToTodayAnimated:YES];
}

- (void)viewDidLoad
{
  self.tableView.scrollEnabled = NO;
  [self setEvents: @[]];
  [super viewDidLoad];
  [GAEvent findAllEventsInBackground:^(NSArray *events, NSError *error) {
    if (error || (events.count == 0)) {
      [self showErrorAlert:error];
    }
    else {
      [self setEvents:events];
      [self.tableView reloadData];
      // Set start and end dates in dayPicker
      [self setDayPickerRange];
      // Then display today in the picker and tableView
      [self goToTodayAnimated:NO];
      self.tableView.scrollEnabled = YES;
    }
  }];
  
  // Do any additional setup after loading the view, typically from a nib.
  [self setupAndFormatDayPicker];
}

-(void)goToTodayAnimated:(BOOL)animated {
  NSDate *keyDate = [[self class] dateAtBeginningOfDayForDate:[NSDate date]];
  NSInteger index = [_sortedDays indexOfObject:keyDate];
  
  if (index != NSNotFound) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: index] atScrollPosition:UITableViewScrollPositionTop animated:animated];
  }
  
  [self.dayPicker setCurrentDate:keyDate animated:animated];
}


#pragma mark - MZDayPickerDelegate methods
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
  return [_dateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
  NSDate *keyDate = [[self class] dateAtBeginningOfDayForDate:day.date];
  NSInteger index = [_sortedDays indexOfObject:keyDate];
  
  //This way we make sure it doesn't crash if things get glitchy and index isn't found.
  if (index != NSNotFound) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
}


#pragma mark - TableView Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Perform segue to event detail
  [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  NSDate *keyDate = _sortedDays[section];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
  [dateFormatter setDateStyle:NSDateFormatterLongStyle];
  return [dateFormatter stringFromDate:keyDate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_sortedDays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSDate *keyDate = _sortedDays[section];
  return [_events[keyDate] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString* reuseIdentifier = @"EventCell";
  
  GAEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  NSDate *keyDate = _sortedDays[indexPath.section];
  GAEvent *event = _events[keyDate][indexPath.row];
  
  cell.title.text = event.title;
  cell.location.text = event.location;
  NSDateIntervalFormatter* formatter = [[NSDateIntervalFormatter alloc] init];
  formatter.dateStyle = NSDateIntervalFormatterNoStyle;
  formatter.timeStyle = NSDateIntervalFormatterShortStyle;
  cell.date.text =  [formatter stringFromDate:event.startTime toDate:event.endTime];
  
  return cell;
}


#pragma mark - Segue Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showEventDetail"]) {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDate *keyDate = _sortedDays[indexPath.section];
    GAEvent *event = _events[keyDate][indexPath.row];

    EventDetailViewController *eventDetailViewController = [segue destinationViewController];
    eventDetailViewController.theEvent = event;
  }
}


#pragma mark - Scrollview Delegate Methods
BOOL _dayPickerIsAnimating = NO;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  NSArray *visibleRows = [self.tableView visibleCells];
  UITableViewCell *firstVisibleCell = [visibleRows objectAtIndex:0];
  NSIndexPath *path = [self.tableView indexPathForCell:firstVisibleCell];
  
  //Scroll to the selected date.
  NSDate *toDate = _sortedDays[path.section];
  BOOL selectedDateIsCurrentlyViewed = [toDate isEqualToDate:_displayedDate];
  
  if (!selectedDateIsCurrentlyViewed){
    _displayedDate = toDate;
    NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:_displayedDate];
    
    NSInteger year = [firstComponents year];
    NSInteger month = [firstComponents month];
    NSInteger day = [firstComponents day];
    
    NSDate *followingDay = [NSDate dateFromDay:day+1 month:month year:year];
    [self.dayPicker setCurrentDate:followingDay animated:YES];
  }
  
}

- (IBAction)goToToday:(id)sender {
  [self goToTodayAnimated:YES];
}

#pragma mark - Utility Methods
- (void)showErrorAlert:(NSError *)error {
  if (error) {
    [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                message:@"There has been an error. Try relaunching the app."
                               delegate:nil
                      cancelButtonTitle:@"No hard feelings"
                      otherButtonTitles:nil, nil] show];
  }
  else {
    [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                message:@"We're doing some server maintenence. Try relaunching the app in a few minutes."
                               delegate:nil
                      cancelButtonTitle:@"No hard feelings"
                      otherButtonTitles:nil, nil] show];
  }
}

- (void)setDayPickerRange {
  [self.dayPicker setStartDate:_sortedDays.firstObject endDate:_sortedDays.lastObject];
}

- (void)setupAndFormatDayPicker {
  
  self.dayPicker.activeDayColor = [UIColor redColor];
  self.dayPicker.bottomBorderColor = [UIColor colorWithRed:0.693 green:0.008 blue:0.207 alpha:1.000];
  self.dayPicker.inactiveDayColor = [UIColor grayColor];
  
  self.dayPicker.delegate = self;
  self.dayPicker.dataSource = self;
  
  self.dayPicker.dayNameLabelFontSize = 12.0f;
  self.dayPicker.dayLabelFontSize = 18.0f;
  
  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setDateFormat:@"EE"];
  
}


#pragma mark - Helper Functions
+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate {
  // Courtesy of https://oleb.net/blog/2011/12/tutorial-how-to-sort-and-group-uitableview-by-date/
  // Use the user's current calendar and time zone
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
  [calendar setTimeZone:timeZone];
  
  // Selectively convert the date components (year, month, day) of the input date
  NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
  
  // Set the time components manually
  [dateComps setHour:0];
  [dateComps setMinute:0];
  [dateComps setSecond:0];
  
  return [calendar dateFromComponents:dateComps];
}
@end
