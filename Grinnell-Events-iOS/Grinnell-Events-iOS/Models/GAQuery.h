//
//  GAQuery.h
//  Grinnell-Events-iOS
//
//  Created by MikeBook Pro on 10/14/18.
//  Copyright © 2018 Grinnell AppDev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GAQuery : NSObject

@property (nonatomic, strong) NSDate *startTime;
- (id)initWithTime;
- (void)findObjectsInBackgroundWithBlock:(void (^)(NSArray *, NSError *))resultBlock;

@end

NS_ASSUME_NONNULL_END
