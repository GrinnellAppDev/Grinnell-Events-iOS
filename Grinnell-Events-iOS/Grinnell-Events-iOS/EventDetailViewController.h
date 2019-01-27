//
//  EventDetailViewController.h
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@class GAEvent;

@interface EventDetailViewController : UITableViewController<UIScrollViewDelegate>

@property (nonatomic, strong) GAEvent *theEvent;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITableViewCell *availabilityCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addToCalendarCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationMapCell;


@end
