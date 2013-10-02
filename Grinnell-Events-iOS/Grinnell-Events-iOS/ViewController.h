//
//  ViewController.h
//  Grinnell-Events-iOS
//
//  Created by Lea Marolt on 9/8/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZDayPicker.h"

@interface ViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *eventsData;
@property (nonatomic, strong) NSArray *flatEventsData;

@property (weak, nonatomic) IBOutlet MZDayPicker *dayPicker;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *filteredEventsArray;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
