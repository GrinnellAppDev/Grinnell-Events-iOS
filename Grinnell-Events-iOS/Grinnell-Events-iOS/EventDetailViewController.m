//
//  EventDetailViewController.m
//  Grinnell-Events-iOS
//
//  Created by Maijid Moujaled on 10/2/13.
//  Copyright (c) 2013 Grinnell AppDev. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventKitController.h"
#import "NSDate+GADate.h"
#import "GAEvent.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface EventDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *conflictLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conflictImageView;
@property (weak, nonatomic) IBOutlet FBSDKShareButton *customShareButton;
@property (nonatomic, strong) EventKitController *eventKitController;

@end

@implementation EventDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = self.theEvent.title;
    self.eventKitController = [[EventKitController alloc] init];
    
    self.timeLabel.text =  [NSString stringWithFormat:@"%@ - %@", [NSDate timeStringFormatFromDate:self.theEvent.startTime], [NSDate timeStringFormatFromDate:self.theEvent.endTime]];
    
    self.dateLabel.text = self.theEvent.date;
    self.locationLabel.text = self.theEvent.location;
    if (self.theEvent.detailDescription) {
        self.descriptionTextView.text = self.theEvent.detailDescription;
    }
    else {
        self.descriptionTextView.text = @"Sorry. No details were given for this event :(";
    }
    
}
- (UIImage*)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
}

- (IBAction)shareButtonClicked:(id)sender {
    
    NSString *shareInfo = [NSString stringWithFormat:@"Hey everyone! Join me at %@ on %@ , %@ at %@", self.title,self.dateLabel.text, self.timeLabel.text, self.locationLabel.text];
    NSLog(@"%@", shareInfo);
    NSDictionary *attributes = @{NSFontAttributeName            : [UIFont systemFontOfSize:20],
                                 NSForegroundColorAttributeName : [UIColor blueColor],
                                 NSBackgroundColorAttributeName : [UIColor clearColor]};
  
//    this part is commented out right now because photo doesn't work with simulator. if testing, uncomment this part and comment out the part from sharelink down
 UIImage *eventdetails = [self imageFromString:shareInfo attributes:attributes size: CGSizeMake(600, 200)];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = eventdetails;
    photo.userGenerated = NO;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
//    [FBSDKShareDialog showFromViewController:self
//                                 withContent:content
//                                    delegate:nil];
}

//got this code from stackoverflow; https://stackoverflow.com/questions/23556269/how-to-convert-text-to-image, 



- (void) viewWillAppear:(BOOL)animated {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self updateConflictCell];
}

- (IBAction)addEventToCalendar:(id)sender {
    
    NSArray *allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    NSPredicate *eventPredicate = [self.eventKitController.eventStore predicateForEventsWithStartDate:self.theEvent.startTime endDate:self.theEvent.endTime calendars:allCalendars];
    NSArray *matchingEvents = [self.eventKitController.eventStore eventsMatchingPredicate:eventPredicate];
    
    if (matchingEvents) {
        NSString *firstConflicting = [matchingEvents.firstObject title];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh! You have conflicts with this event!" message: [NSString stringWithFormat:@"%@ conflicts", firstConflicting]  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Anyway", nil];
        
        [alert show];
    } else {
            [self.eventKitController addEventToCalendar:self.theEvent];
    }
    
    [self updateConflictCell];

}

- (void)updateConflictCell {
    
    
    NSArray *allCalendars = [self.eventKitController.eventStore calendarsForEntityType: EKEntityTypeEvent];
    
    NSPredicate *eventPredicate = [self.eventKitController.eventStore predicateForEventsWithStartDate:self.theEvent.startTime endDate:self.theEvent.endTime calendars:allCalendars];
    
    
    NSArray *matches = [self.eventKitController.eventStore eventsMatchingPredicate:eventPredicate];
    NSMutableArray *matchingEvents = [NSMutableArray arrayWithArray:matches];
    
    //Remove all "all-day" events;
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (EKEvent *event in matchingEvents) {
        if (event.allDay) {
            [tmpArray addObject:event];
//            [matchingEvents removeObject:event];
        }
    }
    [matchingEvents removeObjectsInArray:tmpArray];
    
    if (matchingEvents.count > 0 ) {
        
        EKEvent *firstConflict = matchingEvents.firstObject;
        
        NSString *title = firstConflict.title;
        
        
        
        NSString *start = [NSDate timeStringFormatFromDate:firstConflict.startDate];
        
        NSString *end = [NSDate timeStringFormatFromDate:firstConflict.endDate];
        NSString *conflictText = [NSString stringWithFormat:@"%@ (%@ - %@) conflicts with this event.", title, start, end];
       
        if ([title isEqualToString:self.theEvent.title]) {
            self.conflictLabel.text = @"Looks like you're going to this already!";
            self.conflictImageView.image = [UIImage imageNamed:@"checkmark"];
        } else {
        self.conflictLabel.text = conflictText;
        self.conflictImageView.image = [UIImage imageNamed:@"unavailable"];
        }
    } else {
        self.conflictLabel.text = @"You are free for this event!";
        self.conflictImageView.image = [UIImage imageNamed:@"checkmark"];
    }
    
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
         [self.eventKitController addEventToCalendar:self.theEvent];
    }
}

#pragma mark - Table View Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 1) {
        
        float height = [self findHeightForText:self.theEvent.detailDescription havingWidth:300.0 andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
        
        if (height > 120) {
            return 120;
        }
        else {
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }

    }else {
        // return height from the storyboard
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
}

- (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize+4;
    CGFloat width = widthValue;
    if (text) {
        CGSize textSize = { width, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            //iOS 7
            CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:font}
                                              context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height+1);
        }
        else
        {
            //iOS 6.0
            size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        }
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

@end
