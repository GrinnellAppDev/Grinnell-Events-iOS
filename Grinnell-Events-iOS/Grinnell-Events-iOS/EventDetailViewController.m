//
//  EventDetailViewController.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "EventDetailViewController.h"
#import <EventKit/EventKit.h>

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, readonly) EKEventStore *eventStore;
@property (assign, readonly) BOOL eventAccess;
@property (assign, readonly) BOOL reminderAccess;

@end

@implementation EventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addEventToCalendar:(id)sender {
    
}

@end
