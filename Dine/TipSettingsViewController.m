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
//    [self dismissViewControllerAnimated:YES completion:nil];
//    NSURL *url = [NSURL URLWithString:@"http://www.stackoverflow.com"];
//    
//    if (![[UIApplication sharedApplication] openURL:url]) {
//        NSLog(@"%@%@",@"Failed to open url:",[url description]);
//    }

    
//    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
//    
//    NSString *body = @"&body=It is raining in sunny California!";
//    
//    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//    
//    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    
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
