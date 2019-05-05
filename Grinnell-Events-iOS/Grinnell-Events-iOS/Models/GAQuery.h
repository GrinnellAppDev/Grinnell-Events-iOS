//
//  GAQuery.h
//  Grinnell-Events-iOS
//
//  Created by MikeBook Pro on 10/14/18.
//  Copyright © 2018 Grinnell AppDev. All rights reserved.
//

#import "GAEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GAQuery : NSObject <NSXMLParserDelegate>
// Parser properties - experiment
@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic,strong) NSMutableArray *marrXMLData;
@property (nonatomic,strong) NSMutableString *mstrXMLString;
//@property (nonatomic,strong) NSMutableDictionary *mdictXMLPart;
// maybe change mutableDict to GAEvent
@property (nonatomic,strong) GAEvent *mdictXMLPart;

// Start time to be accessed
@property (nonatomic, strong) NSDate *startTime;

- (id)initWithTime;
- (void)findObjectsInBackgroundWithBlock:(void (^)(NSArray *, NSError *))resultBlock;

@end

NS_ASSUME_NONNULL_END
