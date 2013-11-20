//
//  SettingsViewController.h
//  Grinnell-Events-iOS
//
//  Created by Lea Marolt on 11/3/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventKitController.h"

@interface CalendarsViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *selectedCals;

-(IBAction)done;

@end
