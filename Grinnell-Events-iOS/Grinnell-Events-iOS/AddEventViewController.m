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

@end

@implementation AddEventViewController


- (IBAction)returnButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
