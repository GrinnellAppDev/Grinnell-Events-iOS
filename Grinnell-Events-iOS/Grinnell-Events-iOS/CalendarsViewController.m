#import "CalendarsViewController.h"

@interface CalendarsViewController ()

@property (nonatomic, strong) EventKitController *eventKitController;
@property (nonatomic, strong) NSArray *allCalendars;
@property (nonatomic, strong) NSMutableArray *writableCalendars;
@property (nonatomic, strong) EKCalendar *currentCal;
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;

@end

@implementation CalendarsViewController {
    NSString *selectedCalendarString;
    NSMutableDictionary *calendarTable;
    NSString *savedCal;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    calendarTable = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    // Create array of calendars in a dictionary
    

    EKEventStore *eventStore = [[EKEventStore alloc] init];
    self.eventKitController = [[EventKitController alloc] init];
    
    self.allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    self.writableCalendars = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (EKCalendar *cal in self.allCalendars) {
        if (cal.allowsContentModifications) {
            [self.writableCalendars addObject:cal];
        }
    }
    
    // separate calendars based on their source type
    
    for (EKCalendar *cal in self.writableCalendars) {
        
        if ([calendarTable objectForKey:cal.source.title] != nil) {
            [[calendarTable objectForKey:cal.source.title] addObject:cal];
        }
        else {
            NSMutableArray *sourceArray = [[NSMutableArray alloc] init];
            [sourceArray addObject:cal];
            [calendarTable setObject:sourceArray forKey:cal.source.title];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    selectedCalendarString = [defaults objectForKey:@"selectedCal"];
    
    if (selectedCalendarString == nil) {
        selectedCalendarString = [eventStore defaultCalendarForNewEvents].title;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the types of calendar, not yet implemented
    return [[calendarTable allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[calendarTable objectForKey:[[calendarTable allKeys] objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[calendarTable allKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CalendarItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    UILabel *label = (UILabel *) [cell viewWithTag:13];
    
    // Set label text to calendar's title
    NSString *calKey = [[calendarTable allKeys] objectAtIndex:indexPath.section];
    
    NSArray *calArr = [calendarTable objectForKey:calKey];
    
    self.currentCal = calArr[indexPath.row];
    
    label.text = self.currentCal.title;
    
    if([self.checkedIndexPath isEqual:indexPath] || [label.text isEqualToString:selectedCalendarString])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Set checkmark on current default calendar
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Uncheck the previous checked row
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag:13];
    selectedCalendarString = label.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedCalendarString forKey:@"selectedCal"];
    
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if([self.checkedIndexPath isEqual:indexPath])
    {
        self.checkedIndexPath = nil;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

-(IBAction)done {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.checkedIndexPath];
    
    UILabel *label = (UILabel *) [cell viewWithTag:13];
    selectedCalendarString = label.text;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
