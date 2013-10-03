//
//  EventDetailViewController.h
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GAEvent;

@interface EventDetailViewController : UIViewController

@property (nonatomic, strong) GAEvent *theEvent;

@end
