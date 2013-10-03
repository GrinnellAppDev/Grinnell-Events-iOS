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
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    /*
     _activeDayColor = kDefaultColorDay;
     _activeDayNameColor = kDefaultColorDayName;
     _inactiveDayColor = kDefaultColorInactiveDay;
     _backgroundPickerColor = kDefaultColorBackground;
     _bottomBorderColor = kDefaultColorBottomBorder;
     */
    
    self.dayPicker.activeDayColor = [UIColor redColor];
    self.dayPicker.bottomBorderColor = [UIColor colorWithRed:0.693 green:0.008 blue:0.207 alpha:1.000];
    self.dayPicker.inactiveDayColor = [UIColor grayColor];
    
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dayPickerdateFormatter = [[NSDateFormatter alloc] init];
    [self.dayPickerdateFormatter setDateFormat:@"EE"];
    
    NSDate *tomorr = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
    NSLog(@"date: %@", tomorr);
    
    NSLog(@"GAevents in vdl: %@", self.allEvents);
    
    //Setup Sample data model.
    /*
     GAEvent *e1 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC" andDate:[NSDate date]];
     GAEvent *e2 = [GAEvent eventWithTitle:@"Tiffany's Commemoration" andCategory:@"CSC" andDate:[NSDate date]];
     GAEvent *e3 = [GAEvent eventWithTitle:@"Patrick's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24]];
     GAEvent *e4 = [GAEvent eventWithTitle:@"Colin's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24]];
     GAEvent *e5 = [GAEvent eventWithTitle:@"Spencer's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2]];
     GAEvent *e6 = [GAEvent eventWithTitle:@"Daniel's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2]];
     GAEvent *e7 = [GAEvent eventWithTitle:@"Maijid's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 3]];
     GAEvent *e8 = [GAEvent eventWithTitle:@"Dcow's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 4]];
     GAEvent *e9 = [GAEvent eventWithTitle:@"Rebelsky's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 4]];
     */
    //GAEvent *e0 = [GAEvent eventWithTitle:@"Walkers's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 5]];
    
    /*
     self.eventsData = @[@[e1, e1, e2, e2, e1],
     @[e3, e4, e3, e4],
     @[e5, e5, e5, e5, e6],
     @[e7, e7, e7, e7],
     @[e8, e8, e8, e8]
     ];
     
     //test
     self.flatEventsData = @[e1,e2,e3,e4,e5,e5,e2,e3,e3,e4,e5,e7,e8];
     
     */
    
    
    
    // Initialize the filteredEventsArray with a capacity equal to the event's capacity
    self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [GAEvent findAllEventsInBackground:^(NSArray *objects, NSError *error) {
        if (!error) {
            // NSLog(@"Retrieved: %d, events: %@",objects.count, objects);
            
            GAEvent *event = objects.lastObject;
            
            NSLog(@"date: %@", event.date);
            
            self.allEvents = objects;
            // Need to sort all these events in terms of days.
            
            NSMutableDictionary *theEvents = [[NSMutableDictionary alloc] init];
            
            for (GAEvent *event in objects) {
                
                NSString *eventDate = event.date;
                
                if ( theEvents[eventDate] ) {
                    //It has the meal (Bfast, Lunch, Dinner) so we can just add to this?
                    [theEvents[eventDate] addObject:event];
                } else {
                    //NSMutableDictionary *mealDict = [[NSMutableDictionary alloc] init];
                    theEvents[eventDate] = [[NSMutableArray alloc] init];
                    [theEvents[eventDate] addObject:event];
                    
                    //it doesn't have it so create it.
                }
            }
            self.eventsDictionary = theEvents;
            NSArray *keys = [theEvents allKeys];
            self.sortedDateKeys =  [keys sortedArrayUsingComparator: ^(NSString *d1, NSString *d2) {
                NSDate *date1 = [NSDate dateFromString:d1];
                NSDate *date2 = [NSDate dateFromString:d2];
                
                return [date1 compare:date2];
            }];
            
            [self.tableView reloadData];
            // NSLog(@"sortedDateKeys: %@", sortedDateKeys);
            // NSLog(@"theEvents: %@", theEvents);
            
            //Get the first date of available events
            NSDate *firstDate = [NSDate dateFromString: self.sortedDateKeys.firstObject ];
            NSDate *lastDate = [NSDate dateFromString:self.sortedDateKeys.lastObject];
            
            /*
             NSArray *firstArray = self.eventsData.firstObject;
             GAEvent *firstEvent = firstArray.firstObject;
             
             NSArray *lastArray = self.eventsData.lastObject;
             GAEvent *lastEvent = lastArray.firstObject;
             */
            
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
            
            
        } else {
            NSLog(@"Error: %@ %@ ", error, error.userInfo);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MZDayPickerDelegate methods
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dayPickerdateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    NSLog(@"Did select day %@", day.date);
    
    //We scroll to that section.. somehow.
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
    NSLog(@"Will select day %@",day.day);
}


#pragma mark - UITableView Delegate Methods

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to event detail
    [self performSegueWithIdentifier:@"showEventDetail" sender:tableView];
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
            eventDetailViewController.theEvent = event;
        }
        
        eventDetailViewController.title = event.title;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return  [NSString stringWithFormat:@"Search Results for \"%@\"", self.searchText];
        
    } else {
        /*
         NSArray *sectionArray = [self.eventsData objectAtIndex:section];
         NSDate *sectionDate = [sectionArray[0] date];
         
         NSString *sectionTitle = [NSDateFormatter localizedStringFromDate:sectionDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
         
         return sectionTitle;
         */
        
        //NSLog(@"titleforheaderinsection: %@", self.sortedDateKeys);
        return self.sortedDateKeys[section];
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        //        return self.eventsData.count;
        NSLog(@"self.eventsDictcount: %d", [[self.eventsDictionary allKeys] count]);
        return [[self.eventsDictionary allKeys] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredEventsArray count];
    } else {
        //        return [self.eventsData[section] count];
        //return [self.eventsDictionary[section] count];
        NSLog(@"numrows: %d" , [self.eventsDictionary[self.sortedDateKeys[section]] count]);
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
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        event = self.filteredEventsArray[indexPath.row];
    } else {
        //        event = self.eventsData[indexPath.section][indexPath.row];
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
    NSLog(@"Scroll view did scroll!!");
    
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *firstVisibleCell = [visibleRows objectAtIndex:0];
    NSIndexPath *path = [self.tableView indexPathForCell:firstVisibleCell];
    
    
    //Scroll to that date. -- Need a way to link the indexPath with a date.
    int ps = path.section + 2;
    NSLog(@"ps: %d", ps);
    
    NSArray *eventsArray = [self.eventsData objectAtIndex:path.section];
    
    NSDate *toDate = [NSDate dateFromString:self.sortedDateKeys[path.section] ];
    
    //  GAEvent *event = eventsArray[path.row];
    
    NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:toDate];
    
    int year = [firstComponents year];
    int month = [firstComponents month];
    int day = [firstComponents day];
    
    //if (!_dayPickerIsAnimating) {
    //   _dayPickerIsAnimating = YES;
    [self.dayPicker setCurrentDate:[NSDate dateFromDay:day+1 month:month year:year] animated:YES];
    //   _dayPickerIsAnimating = NO;
    // }
    
    
}



#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    
    // Remove all objects from the filtered search array
    self.searchText = searchText;
    
    [self.filteredEventsArray removeAllObjects];
    
    // Filter the array using NSPredicate
    [self.filteredEventsArray removeAllObjects];
    
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
