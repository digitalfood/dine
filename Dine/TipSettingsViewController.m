//
//  TipSettingsViewController.m
//  Dine
//
//  Created by Fabián Uribe Herrera on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "TipSettingsViewController.h"

@interface TipSettingsViewController ()

@end

@implementation TipSettingsViewController
- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)onApply:(id)sender {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
