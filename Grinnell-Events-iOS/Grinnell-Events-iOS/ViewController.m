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
    [GAEvent findAllEventsInBackground:^(NSArray *events, NSError *error) {
        if (error || (events.count == 0)) {
            [self showErrorAlert:error];
        }
        else {
            NSMutableDictionary *unfilteredEvents = [self populateEventsDictionary:self.allEvents];
            
            self.sortedDateKeys = [self sortDictionaryKeysByDate:unfilteredEvents];
            
            NSLog(@"Sorted keys 2: %@", self.sortedDateKeys);
            [self filterContentForSearchText:@"" scope:
             [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
            
            [self.tableView reloadData];
            
            // Set start and end dates in dayPicker
            
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
    //self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
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
    NSString *selectedDateString = [NSDate formattedStringFromDate:day.date];
    NSInteger index = [self.sortedDateKeys indexOfObject:selectedDateString];
    
    //This way we make sure it doesn't crash if things get glitchy and index isn't found.
    if (index != NSNotFound) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


#pragma mark - UITableView Delegate Methods


#pragma mark - TableView Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to event detail
    [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    cell.title.text = event.title;
    cell.location.text = event.location;
    cell.date.text =  [NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:event.startTime], [NSDate timeStringFormatFromDate:event.endTime]];
    
    return cell;
}


#pragma mark - Segue Methods
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


#pragma mark - Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    // Erase events from previous search
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
     self.filteredSortedDateKeys = [newKeys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
         NSDate *date1 = [NSDate dateFromString:d1];
         NSDate *date2 = [NSDate dateFromString:d2];
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
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar
                                                                                selectedScopeButtonIndex]]];
    [self.tableView reloadData];
    
}

- (IBAction)didTapDays:(id)sender {
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

- (NSMutableDictionary *)populateEventsDictionary:(NSArray *)events {
    
    self.allEvents = events;
    NSMutableDictionary *eventsDictionary = [[NSMutableDictionary alloc] init];
    
    for (GAEvent *event in events) {
        NSString *eventDate = event.date;
        
        if ( eventsDictionary[eventDate] ) {
            /* It has an array with this date. Add to event to existing array. */
            [eventsDictionary[eventDate] addObject:event];
        } else {
            /* Create the array and add event */
            eventsDictionary[eventDate] = [[NSMutableArray alloc] init];
            [eventsDictionary[eventDate] addObject:event];
        }
    }
    
    return eventsDictionary;

}

- (NSArray *)sortDictionaryKeysByDate:(NSMutableDictionary *)unfilteredEvents {
    
    NSArray *keys = [self.filteredEventsDictionary allKeys];
    return [keys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
        NSDate *date1 = [NSDate dateFromString:d1];
        NSDate *date2 = [NSDate dateFromString:d2];
        return [date1 compare:date2];
    }];
    
}

- (void)setDayPickerRange {
    
    NSDate *firstDate = [NSDate dateFromString: self.sortedDateKeys.firstObject ];
    NSDate *lastDate = [NSDate dateFromString:self.sortedDateKeys.lastObject];
    
    NSInteger *initialDate = [self parseDateComponents:firstDate];
    NSInteger *finalDate = [self parseDateComponents:lastDate];
    
    [self.dayPicker setStartDate:[NSDate dateFromDay:initialDate[0] month:initialDate[1] year:initialDate[2]] endDate:[NSDate dateFromDay:finalDate[0] month:finalDate[1] year:finalDate[2]]];
    
}

- (NSInteger *)parseDateComponents:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    static NSInteger dateNumbers[3];
    dateNumbers[0] = [components year];
    dateNumbers[1] = [components month];
    dateNumbers[2] = [components day];
    return dateNumbers;
}


@end
