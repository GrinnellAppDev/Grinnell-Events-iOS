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

@interface ViewController () <MZDayPickerDelegate, MZDayPickerDataSource>
@property (nonatomic,strong) NSDateFormatter *dayPickerdateFormatter;
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
    
    
    //Setup Sample data model.
    
    GAEvent *e1 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e2 = [GAEvent eventWithTitle:@"Tiffany's Commemoration" andCategory:@"CSC"];
    GAEvent *e3 = [GAEvent eventWithTitle:@"Patrick's Commemoration" andCategory:@"CSC"];
    GAEvent *e4 = [GAEvent eventWithTitle:@"Colin's Commemoration" andCategory:@"CSC"];
    GAEvent *e5 = [GAEvent eventWithTitle:@"Spencer's Commemoration" andCategory:@"CSC"];
    GAEvent *e6 = [GAEvent eventWithTitle:@"Daniel's Commemoration" andCategory:@"CSC"];
    GAEvent *e7 = [GAEvent eventWithTitle:@"Maijid's Commemoration" andCategory:@"CSC"];
    GAEvent *e8 = [GAEvent eventWithTitle:@"Dcow's Commemoration" andCategory:@"CSC"];
    GAEvent *e9 = [GAEvent eventWithTitle:@"Rebelsky's Commemoration" andCategory:@"CSC"];
    GAEvent *e0 = [GAEvent eventWithTitle:@"Walkers's Commemoration" andCategory:@"CSC"];

    
    self.eventsData = @[@[e1, e2, e2, e4, e4, e6],
                        @[e5, e6, e3, e2, e1],
                        @[e4, e6, e7, e0, e8, e7],
                        @[e2, e2, e5, e6, e6, e7, e7, e8, e0],
                        @[e1, e1, e4, e5, e2, e6, e6, e5, e9]];
    
    
    //Set up initial DatePicker values
    [self.dayPicker setStartDate:[NSDate dateFromDay:1 month:9 year:2013] endDate:[NSDate dateFromDay:5 month:9 year:2013]];
    [self.dayPicker setCurrentDate:[NSDate dateFromDay:1 month:9 year:2013] animated:NO];

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
    return  [NSString stringWithFormat:@"Section for Day %d", section + 1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.eventsData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.eventsData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"EventCell";
    
    GAEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[GAEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    GAEvent *event = self.eventsData[indexPath.section][indexPath.row];
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
    
    //if (!_dayPickerIsAnimating) {
    //   _dayPickerIsAnimating = YES;
    [self.dayPicker setCurrentDate:[NSDate dateFromDay:ps month:9 year:2013] animated:YES];
    //   _dayPickerIsAnimating = NO;
    // }
    
    
}


@end
