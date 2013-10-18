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
@property (nonatomic, strong) NSDictionary *eventsDictionary;
@property (nonatomic, strong) NSArray *sortedDateKeys;

@property (nonatomic, assign) BOOL datePickerSet;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
   // NSDate *tomorr = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
   // NSLog(@"date: %@", tomorr);
    
    NSLog(@"GAevents in vdl: %@", self.allEvents);
    
    
    // Initialize the filteredEventsArray with a capacity equal to the event's capacity
    self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [GAEvent findAllEventsInBackground:^(NSArray *events, NSError *error) {
        if (!error) {
            // NSLog(@"Retrieved: %d, events: %@",objects.count, objects);
            
            self.allEvents = events;
            NSMutableDictionary *theEvents = [[NSMutableDictionary alloc] init];
            
            for (GAEvent *event in events) {
                NSString *eventDate = event.date;
            
                if ( theEvents[eventDate] ) {
                    /* It has an array with this date. Add to event to existing array. */
                    [theEvents[eventDate] addObject:event];
                } else {
                    /* Create the array and add event */
                    theEvents[eventDate] = [[NSMutableArray alloc] init];
                    [theEvents[eventDate] addObject:event];
                }
            }
            
            self.eventsDictionary = theEvents;
            // Sort the keys by date
            NSArray *keys = [theEvents allKeys];
            self.sortedDateKeys =  [keys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
                NSDate *date1 = [NSDate dateFromString:d1];
                NSDate *date2 = [NSDate dateFromString:d2];
                return [date1 compare:date2];
            }];
            
            [self.tableView reloadData];

            /* Set the DatePicker with first and last event values */
            // TODO (DrJid): Might need to do this elsewhere since the picker is reset when back button is pressed in event Detail view
            // Using this boolean to fix above. Assuming that the datePicker wouldn't need to reset all the time under viewWillAppear.
            if (!self.datePickerSet) {
                NSDate *firstDate = [NSDate dateFromString: self.sortedDateKeys.firstObject ];
                NSDate *lastDate = [NSDate dateFromString:self.sortedDateKeys.lastObject];
                
                NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:firstDate];
                
                int firstYear = [firstComponents year];
                int firstMonth = [firstComponents month];
                int firstDay = [firstComponents day];
                
                NSDateComponents *lastComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:lastDate];
                int lastYear = [lastComponents year];
                int lastMonth = [lastComponents month];
                int lastDay = [lastComponents day];
                
                NSLog(@"firstYear: %d, firstMonth: %d, firstDay: %d" , firstYear, firstMonth, firstDay);
                
                //Set up initial DatePicker values
                [self.dayPicker setStartDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] endDate:[NSDate dateFromDay:lastDay month:lastMonth year:lastYear]];
                [self.dayPicker setCurrentDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] animated:NO];
                self.datePickerSet = YES;
            }
        } else {
            NSLog(@"Error: %@ %@ ", error, error.userInfo);
        }
    }];
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
    NSLog(@"sd: %@", selectedDateString);
    int index = [self.sortedDateKeys indexOfObject:selectedDateString];
    
    //This way we make sure it doesn't crash if things get glitchy and index isn't found.
    if (index != NSNotFound) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    //NSLog(@"Will select day %@",day.day);
}


#pragma mark - UITableView Delegate Methods

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to event detail
    [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEventDetail"]) {
        
        EventDetailViewController *eventDetailViewController = [segue destinationViewController];
        GAEvent *event;
        
        // In order to manipulate the destination view controller, another check on which table (search or normal) is displayed is needed
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            event = self.filteredEventsArray[indexPath.row];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSString *dateKey =  self.sortedDateKeys[indexPath.section];
            event = self.eventsDictionary[dateKey][indexPath.row];
        }
        
        eventDetailViewController.theEvent = event;
        eventDetailViewController.title = event.title;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return  [NSString stringWithFormat:@"Search Results for \"%@\"", self.searchText];
    } else {
        // Return the apt section title.
        return self.sortedDateKeys[section];
    }
}

/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 UIView *scarletView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
 scarletView.backgroundColor = [UIColor colorWithRed:0.693 green:0.008 blue:0.207 alpha:1.000];
 
 UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
 
 // textLabel.textColor = [UIColor whiteColor];
 textLabel.backgroundColor = [UIColor clearColor];
 textLabel.text = self.sortedDateKeys[section];
 [scarletView addSubview:textLabel];
 
 return scarletView;
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
       // NSLog(@"self.eventsDictcount: %d", [[self.eventsDictionary allKeys] count]);
        return [[self.eventsDictionary allKeys] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredEventsArray count];
    } else {
        //NSLog(@"numrows: %d" , [self.eventsDictionary[self.sortedDateKeys[section]] count]);
        return [self.eventsDictionary[self.sortedDateKeys[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"EventCell";
    
    GAEventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[GAEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    GAEvent *event;
    
    // Check to see whether the normal table or search results table is being displayed and set the Event object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        event = self.filteredEventsArray[indexPath.row];
    } else {
        NSString *dateKey =  self.sortedDateKeys[indexPath.section];
        event = self.eventsDictionary[dateKey][indexPath.row];
    }
    
    cell.title.text = event.title;
    cell.location.text = event.location;
    cell.date.text =  [NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:event.startTime], [NSDate timeStringFormatFromDate:event.endTime]];
    
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
    NSDate *toDate = [NSDate dateFromString:self.sortedDateKeys[path.section] ];
    
    NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:toDate];
    
    int year = [firstComponents year];
    int month = [firstComponents month];
    int day = [firstComponents day];

    [self.dayPicker setCurrentDate:[NSDate dateFromDay:day+1 month:month year:year] animated:YES];
}



#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    self.searchText = searchText;

    // Remove all objects from the filtered search array
    [self.filteredEventsArray removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    
    self.filteredEventsArray = [NSMutableArray arrayWithArray:[self.allEvents filteredArrayUsingPredicate:predicate]];
    NSLog(@"fileteredArr: %@" , self.filteredEventsArray);
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


@end
