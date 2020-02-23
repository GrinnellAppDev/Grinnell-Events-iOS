//
//  ViewController.m
//  Grinnell-Events-iOS
//
//  Created by Lea Marolt on 9/8/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "ViewController.h"
#import "GAEvent.h"
#import "GAEventCell.h"
#import "NSDate+GADate.h"
#import "EventDetailViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>


@interface ViewController () <MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong) NSDateFormatter *dayPickerdateFormatter;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSArray *allEvents;
@property (nonatomic, strong) NSDictionary *filteredEventsDictionary;
@property (nonatomic, strong) NSArray *sortedDateKeys;
@property (nonatomic, strong) NSArray *filteredSortedDateKeys;
@property (nonatomic, strong) NSDate *focusedDate;




- (IBAction)goToToday:(id)sender;

@end

@implementation ViewController

- (IBAction)didDoubleTapDays:(id)sender {
    [self goToTodayAnimated:YES];
}

- (void)viewDidLoad
{
    
    self.tableView.scrollEnabled = NO;
    [super viewDidLoad];
    [GAEvent findAllEventsInBackground:^void (NSArray *events, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@ ", error, error.userInfo);
            [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                        message:@"There has been an error. Try relaunching the app."
                                       delegate:nil
                              cancelButtonTitle:@"No hard feelings"
                              otherButtonTitles:nil, nil] show];
        }
        else if (events.count == 0){
            [[[UIAlertView alloc] initWithTitle:@"Sorry about this..."
                                        message:@"We're doing some server maintenence. Try relaunching the app in a few minutes."
                                       delegate:nil
                              cancelButtonTitle:@"No hard feelings"
                              otherButtonTitles:nil, nil] show];
        }
        else {
            self.allEvents = events;
            NSLog(@"%lu", [self.allEvents count]);
            NSMutableDictionary *theEvents = [[NSMutableDictionary alloc] init];
            
            for (GAEvent *event in events) {
                NSString *eventDate = [event.date stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
                
                if ( theEvents[eventDate] ) {
                    /* It has an array with this date. Add to event to existing array. */
                    [theEvents[eventDate] addObject:event];
                } else {
                    /* Create the array and add event */
                    theEvents[eventDate] = [[NSMutableArray alloc] init];
                    [theEvents[eventDate] addObject:event];
                }
            }
            
            self.filteredEventsDictionary = theEvents;
            // Sort the keys by date
            NSArray *keys = [theEvents allKeys];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy/MM/dd";
            NSLog(@"%@ is the first key", keys.firstObject);
            self.sortedDateKeys =  [keys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
                NSDate *date1 = [dateFormatter dateFromString:d1];
                NSDate *date2 = [dateFormatter dateFromString:d2];
                return [date1 compare:date2];
            }];
            NSLog(@"%@ is the first sorted key", self.sortedDateKeys.firstObject);
            NSLog(@"%@ is the last sorted key", self.sortedDateKeys.lastObject);
            
            [self filterContentForSearchText:@"" scope:
             [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
            
            [self.tableView reloadData];
            //set dateformatter in order to convert string to date
            NSString *firstDateString = self.sortedDateKeys.firstObject;
            NSString *lastDateString = self.sortedDateKeys.lastObject;
            
            NSDate *firstDate = [dateFormatter dateFromString:firstDateString];
            NSDate *lastDate = [dateFormatter dateFromString:lastDateString];
            // Set start and end dates in dayPicker
            //commented out this line of code because the date format was not set correctly
            //NSDate *firstDate = [NSDate dateFromString: self.sortedDateKeys.firstObject ];
            //NSDate *lastDate = [NSDate dateFromString:self.sortedDateKeys.lastObject];
            NSLog(@"First date is %@", firstDate.description);
            //right now last Date is same as first Date...
            NSLog(@"Last date is %@", lastDate.description);
            //sets calendar day to current date
            NSCalendar *curCal = [NSCalendar currentCalendar];
            
            //Find the number of days between the first and last dates
            NSTimeInterval secondsBetween = [lastDate timeIntervalSinceDate:firstDate];
            NSInteger numberOfDays = secondsBetween / 86400;
            
            //Set end date using number of days between first and last dates
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = numberOfDays + 1;
            NSDate *weekFromCurrentDate = [curCal dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
            [self.dayPicker setStartDate: firstDate endDate:weekFromCurrentDate];
            [self.dayPicker setCurrentDate:[NSDate date] animated:NO];
            //commented this line out similarly because last date is 11/04/2018
            //[self.dayPicker setStartDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] endDate:[NSDate dateFromDay:lastDay month:lastMonth year:lastYear]];
            // Then display today in the picker and tableView
            [self goToTodayAnimated:NO];
            self.tableView.scrollEnabled = YES;
        }
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.dayPicker.activeDayColor = [UIColor redColor];
    self.dayPicker.bottomBorderColor = [UIColor colorWithRed:0.693 green:0.008 blue:0.207 alpha:1.000];
    self.dayPicker.inactiveDayColor = [UIColor grayColor];
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    self.dayPickerdateFormatter = [[NSDateFormatter alloc] init];
    [self.dayPickerdateFormatter setDateFormat:@"EE"];
    self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
  
    
}

-(void)viewWillAppear:(BOOL)animated {
    
}


-(void)goToTodayAnimated:(BOOL)animated {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps1 = [cal components:(NSCalendarUnitMonth| NSCalendarUnitYear | NSCalendarUnitDay) fromDate:[NSDate date]];
    
    for (int i = 0 ; i < self.sortedDateKeys.count; i++){
        NSDateComponents *comps2 = [cal components:(NSCalendarUnitMonth| NSCalendarUnitYear | NSCalendarUnitDay) fromDate:[NSDate dateFromString:self.sortedDateKeys[i]]];
        if (comps1.day == comps2.day && comps1.month == comps2.month && comps1.year == comps2.year){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: i] atScrollPosition:UITableViewScrollPositionTop animated:animated];
            break;
        }
    }
    
    [self.dayPicker setCurrentDate:[NSDate date] animated:animated];
}


#pragma mark - MZDayPickerDelegate methods
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dayPickerdateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    //We scroll to that section. Sections are labeled by the date (sortedKeys)
    //initialize dateFormatter and dateFormat
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //need to set date
    // dateFormatter.dateFormat = @"ccc MMM dd yyyy";
    //NSString *selectedDateString = [NSDate formattedStringFromDate:day.date];
    //NSDate *dateFromString = [dateFormatter dateFromString: selectedDateString];
    //get string back from NSDATE in correct format
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSString *stringFromDate = [dateFormatter stringFromDate: day.date];
    NSLog(@"the selected date is %@", stringFromDate);
    NSInteger index = [self.sortedDateKeys indexOfObject: stringFromDate];
    NSLog(@"the selected date is %@", self.sortedDateKeys.firstObject); //OH NO!
    NSLog(@"%ld is the index", (long)index);
    //This way we make sure it doesn't crash if things get glitchy and index isn't found.
    if (index != NSNotFound) {
        NSLog(@"index found gg");
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    
    NSLog(@"Will select day %@",day.day);
}

#pragma mark - UITableView Delegate Methods

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to event detail
    [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// prepare for moving to showEventDetail view
#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEventDetail"]) {
        EventDetailViewController *eventDetailViewController = [segue destinationViewController];
        GAEvent *event;
        NSIndexPath *indexPath;
        if (sender == self.searchDisplayController.searchResultsTableView) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        } else if (sender == self.tableView) {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        NSString *key = self.filteredSortedDateKeys[indexPath.section];
        event = self.filteredEventsDictionary[key][indexPath.row];
        eventDetailViewController.theEvent = event;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.filteredSortedDateKeys[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.filteredEventsDictionary allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredEventsDictionary[self.filteredSortedDateKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"EventCell";
    GAEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    GAEvent *event;
    NSString *key = self.filteredSortedDateKeys[indexPath.section];
    
    event = self.filteredEventsDictionary[key][indexPath.row];
    cell.title.hidden = false;
    cell.title.text = [event.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.location.text = [event.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.date.text =  [[NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:event.startTime], [NSDate timeStringFormatFromDate:event.endTime]] stringByAppendingString:event.overnight];
    
    return cell;
}

#pragma mark - Scrollview Delegate Methods
BOOL _dayPickerIsAnimating = NO;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *firstVisibleCell = [visibleRows objectAtIndex:0];
    NSIndexPath *path = [self.tableView indexPathForCell:firstVisibleCell];
    //Scroll to the selected date.
    NSDate *toDate = [NSDate dateFromString:self.filteredSortedDateKeys[path.section] ];
    BOOL selectedDateIsCurrentlyViewed = [toDate isEqualToDate:self.focusedDate];
    
    if (!selectedDateIsCurrentlyViewed){
        self.focusedDate = toDate;
        NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.focusedDate];
        NSInteger year = [firstComponents year];
        NSInteger month = [firstComponents month];
        NSInteger day = [firstComponents day];
        NSDate *followingDay = [NSDate dateFromDay:day+1 month:month year:year];
        [self.dayPicker setCurrentDate:followingDay animated:YES];
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Remove all objects from the filtered search array
    [self.filteredEventsArray removeAllObjects];
    // Update the filtered array based on the search text and scope.
    self.searchText = searchText;
    //http://stackoverflow.com/questions/15091155/nspredicate-match-any-characters
    NSMutableString *searchWithWildcards = [NSMutableString stringWithFormat:@"*%@*", searchText];
    if (searchWithWildcards.length > 3) {
        for (int i = 2; i < self.searchText.length * 2; i += 2) {
            [searchWithWildcards insertString:@"*" atIndex:i];
        }
    }
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.title LIKE[cd] %@)", searchWithWildcards];
    self.filteredEventsArray = [NSMutableArray arrayWithArray:[self.allEvents filteredArrayUsingPredicate:predicate]];
    NSMutableDictionary *searchEvents = [[NSMutableDictionary alloc] init];
    for (GAEvent *event in self.filteredEventsArray) {
        NSString *eventDate = event.date;
        if ( searchEvents[eventDate] ) {
            [searchEvents[eventDate] addObject:event];
        } else {
            searchEvents[eventDate] = [[NSMutableArray alloc] init];
            [searchEvents[eventDate] addObject:event];
        }
    }
    self.filteredEventsDictionary = searchEvents;
    NSArray *newKeys = [searchEvents allKeys];
    //initialize dateFormatter and dateFormat
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    self.filteredSortedDateKeys =  [newKeys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
        NSDate *date1 = [dateFormatter dateFromString:d1];
        NSDate *date2 = [dateFormatter dateFromString:d2];
        return [date1 compare:date2];
    }];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    //Search Results Table View has a different Row height - Fix it to use the height of our prototype cell
    tableView.rowHeight = 72;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar {
    [self filterContentForSearchText:@"" scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    [self.tableView reloadData];
}

- (IBAction)didTapDays:(id)sender {
}

- (IBAction)goToToday:(id)sender {
    [self goToTodayAnimated:YES];
    //We scroll to that section. Sections are labeled by the date (sortedKeys)
    //initialize dateFormatter and dateFormat
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //need to set date
    // dateFormatter.dateFormat = @"ccc MMM dd yyyy";
    //NSString *selectedDateString = [NSDate formattedStringFromDate:day.date];
    //NSDate *dateFromString = [dateFormatter dateFromString: selectedDateString];
    //get string back from NSDATE in correct format
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"the selected date is %@", stringFromDate);
    NSInteger index = [self.sortedDateKeys indexOfObject: stringFromDate];
    NSLog(@"the selected date is %@", self.sortedDateKeys.firstObject); //OH NO!
    NSLog(@"%ld is the index", (long)index);
    //This way we make sure it doesn't crash if things get glitchy and index isn't found.
    if (index != NSNotFound) {
        NSLog(@"index found gg");
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
@end

