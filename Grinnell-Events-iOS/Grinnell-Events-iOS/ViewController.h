#import <UIKit/UIKit.h>
#import "MZDayPicker.h"

@interface ViewController : UIViewController <UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet MZDayPicker *dayPicker;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
