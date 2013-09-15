//
//  GAEvent.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 9/15/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "GAEvent.h"

@implementation GAEvent


- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}


+ (instancetype) eventWithTitle:(NSString *)aTitle andCategory:(NSString *)aCategory
{
    GAEvent *event = [[GAEvent alloc] init];
    event.title = aTitle;
    event.category = aCategory;
    
    return event;
}


@end
