//
//  AddEventViewController.m
//  Grinnell-Events-iOS
//
//  Created by Cherie Li on 2/27/19.
//  Copyright © 2019 Grinnell AppDev. All rights reserved.
//

#import "AddEventViewController.h"

@interface AddEventViewController ()
- (IBAction)returnButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *personName;
@property (weak, nonatomic) IBOutlet UITextField *eventName;
@property (weak, nonatomic) IBOutlet UITextField *clubName;
@property (weak, nonatomic) IBOutlet UITextField *eventTimeDate;

@end

@implementation AddEventViewController


- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.personName.delegate = self;
    self.eventName.delegate = self;
    self.clubName.delegate = self;
    self.eventTimeDate.delegate = self;
}
enum {
    personNameTag = 0,
    eventNameTag = 1,
    clubNameTag = 2,
    eventTimeDateTag = 3
};
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    switch(textField.tag){
        case personNameTag:
            [_eventName becomeFirstResponder];
            break;
        case eventNameTag:
            [_clubName becomeFirstResponder];
            break;
        case clubNameTag:
            [_eventTimeDate becomeFirstResponder];
            break;
        default:
            [_eventTimeDate resignFirstResponder];
            
    }
    return true;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
