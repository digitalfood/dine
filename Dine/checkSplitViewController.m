//
//  checkSplitViewController.m
//  Dine
//
//  Created by Fabián Uribe Herrera on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "CheckSplitViewController.h"

@interface CheckSplitViewController ()
@property (weak, nonatomic) IBOutlet UITextField *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;

@property (nonatomic, assign) float splitAmount;

@end

@implementation CheckSplitViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.countStepper.minimumValue = 2;
    self.countStepper.value = 2;
    
    [self splitBill];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)stepperValueChanged:(id)sender {
    [self splitBill];
}

- (void) splitBill {
    self.countLabel.text = [NSString stringWithFormat: @"%i", (int) self.countStepper.value];
    self.splitAmount =  self.amount/self.countStepper.value;
    self.amountLabel.text = [NSString stringWithFormat: @"$%0.2f", self.splitAmount];

}


- (IBAction)onDoneBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onRequestBtn:(id)sender {

}


@end
