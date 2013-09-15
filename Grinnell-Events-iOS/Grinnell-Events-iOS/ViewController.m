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
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
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
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"EE"];
    
    GAEvent *e1 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e2 = [GAEvent eventWithTitle:@"Tiffany's Commemoration" andCategory:@"CSC"];
    GAEvent *e3 = [GAEvent eventWithTitle:@"Patrick's Commemoration" andCategory:@"CSC"];
    GAEvent *e4 = [GAEvent eventWithTitle:@"Colin's Commemoration" andCategory:@"CSC"];
    GAEvent *e5 = [GAEvent eventWithTitle:@"Spencer's Commemoration" andCategory:@"CSC"];
    GAEvent *e6 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e7 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e8 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e9 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];
    GAEvent *e0 = [GAEvent eventWithTitle:@"Lea's Commemoration" andCategory:@"CSC"];

    
    self.eventsData = @[@[e1, e2, e2, e4, e4, e6],
                        @[e5, e6, e3, e2, e1],
                        @[e4, e6, e7, e0, e8, e7],
                        @[e2, e2, e5, e6, e6, e7, e7, e8, e0],
                        @[e1, e1, e4, e5, e2, e6, e6, e5, e5]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MZDayPickerDelegate methods
- (NSString *)dayPicker:(MZDayPicker *)dayPicker titleForCellDayNameLabelInDay:(MZDay *)day
{
    return [self.dateFormatter stringFromDate:day.date];
}

- (void)dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day
{
    NSLog(@"Did select day %@",day.day);
    
    //We scroll to that section.. somehow.
    int dayint = [day.day intValue] - 1;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:dayint] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    // if (animate == NO) [self showFirstHeaderLine:NO];
    
    
    
    //[self.tableData addObject:day];
    // [self.tableView reloadData];
}

- (void)dayPicker:(MZDayPicker *)dayPicker willSelectDay:(MZDay *)day
{
    NSLog(@"Will select day %@",day.day);
}


#pragma mark - UITableView Methods

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
    
    //    MZDay *day = self.tableData[indexPath.row];
    
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@",day.day];
    //    cell.detailTextLabel.text = day.name;
    
    GAEvent *event = self.eventsData[indexPath.section][indexPath.row];
    cell.title.text = event.title;
    return cell;
}


@end
