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

#import <Parse/Parse.h>


@interface ViewController () <MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong) NSDateFormatter *dayPickerdateFormatter;
@property (nonatomic, strong) NSString *searchText;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    
    self.dayPicker.dayNameLabelFontSize = 12.0f;
    self.dayPicker.dayLabelFontSize = 18.0f;
    
    self.dayPickerdateFormatter = [[NSDateFormatter alloc] init];
    [self.dayPickerdateFormatter setDateFormat:@"EE"];
    
    
    
    NSDate *tomorr = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
    NSLog(@"date: %@", tomorr);
    
    //Setup Sample data model.
    GAEvent *e1 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC" andDate:[NSDate date]];
    GAEvent *e2 = [GAEvent eventWithTitle:@"Tiffany's Commemoration" andCategory:@"CSC" andDate:[NSDate date]];
    GAEvent *e3 = [GAEvent eventWithTitle:@"Patrick's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24]];
    GAEvent *e4 = [GAEvent eventWithTitle:@"Colin's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24]];
    GAEvent *e5 = [GAEvent eventWithTitle:@"Spencer's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2]];
    GAEvent *e6 = [GAEvent eventWithTitle:@"Daniel's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 2]];
    GAEvent *e7 = [GAEvent eventWithTitle:@"Maijid's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 3]];
    GAEvent *e8 = [GAEvent eventWithTitle:@"Dcow's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 4]];
    GAEvent *e9 = [GAEvent eventWithTitle:@"Rebelsky's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 4]];
    
    //GAEvent *e0 = [GAEvent eventWithTitle:@"Walkers's Commemoration" andCategory:@"CSC" andDate:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 5]];
    
    
    self.eventsData = @[@[e1, e1, e2, e2, e1],
                        @[e3, e4, e3, e4],
                        @[e5, e5, e5, e5, e6],
                        @[e7, e7, e7, e7],
                        @[e8, e8, e8, e8]
                        ];
    
    //test
    self.flatEventsData = @[e1,e2,e3,e4,e5,e5,e2,e3,e3,e4,e5,e7,e8];
    
    
    
    //Get the first date of available events
    NSArray *firstArray = self.eventsData.firstObject;
    GAEvent *firstEvent = firstArray.firstObject;
    
    NSArray *lastArray = self.eventsData.lastObject;
    GAEvent *lastEvent = lastArray.firstObject;
    
    NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:firstEvent.date];
    
    int firstYear = [firstComponents year];
    int firstMonth = [firstComponents month];
    int firstDay = [firstComponents day];
    
    
    NSDateComponents *lastComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:lastEvent.date];
    int lastYear = [lastComponents year];
    int lastMonth = [lastComponents month];
    int lastDay = [lastComponents day];
    
    NSLog(@"firstYear: %d, firstMonth: %d, firstDay: %d" , firstYear, firstMonth, firstDay);
    
    
    //Set up initial DatePicker values
    [self.dayPicker setStartDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] endDate:[NSDate dateFromDay:lastDay month:lastMonth year:lastYear]];
    [self.dayPicker setCurrentDate:[NSDate dateFromDay:firstDay month:firstMonth year:firstYear] animated:NO];
    
    
    // Initialize the filteredEventsArray with a capacity equal to the event's capacity
    self.filteredEventsArray = [NSMutableArray arrayWithCapacity:self.flatEventsData.count];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    //Find messages where ourcurrent user id is in the recipients id.
    query.limit = 300; 
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //We found messages
            //self.messages = objects;
            NSLog(@"Retrieved: %d ,events: %@",objects.count,  objects);
            //[self.tableView reloadData];
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
    NSLog(@"Did select day %@", day.day);
    
    //We scroll to that section.. somehow.
    int dayint = [day.day intValue] - 1;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:dayint] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    NSLog(@"Will select day %@",day.day);
}


#pragma mark - UITableView Delegate Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return  [NSString stringWithFormat:@"Search Results for \"%@\"", self.searchText];
        
    } else {
        NSArray *sectionArray = [self.eventsData objectAtIndex:section];
        NSDate *sectionDate = [sectionArray[0] date];
        
        NSString *sectionTitle = [NSDateFormatter localizedStringFromDate:sectionDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        
        return sectionTitle;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return self.eventsData.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredEventsArray count];
    } else {
        return [self.eventsData[section] count];
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
        event = self.eventsData[indexPath.section][indexPath.row];
    }
    
    cell.title.text = event.title;
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
    
    GAEvent *event = eventsArray[path.row];
    
    NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:event.date];
    
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
    
    self.filteredEventsArray = [NSMutableArray arrayWithArray:[self.flatEventsData filteredArrayUsingPredicate:predicate]];
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
