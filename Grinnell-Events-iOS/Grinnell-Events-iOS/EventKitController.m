//
//  EventKitController.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "EventKitController.h"

@implementation EventKitController


- (id)init
{
    self = [super init];
    if (self) {
        _eventStore = [[EKEventStore alloc] init];
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                _eventAccess = YES;
            } else {
                  NSLog(@"Event access not granted: %@", error);
            }
        }];
        
    }
    return self;
}
@end
