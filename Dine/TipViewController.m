//
//  TipViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/12/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TipViewController.h"
#import "CheckSplitViewController.h"
#import "TipSettingsViewController.h"

@interface TipViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UIView *viewHandle;
@property (weak, nonatomic) IBOutlet UIButton *splitBtn;


@property (nonatomic, assign) float totalAmount;


@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, assign) double billAmount;
@property (weak, nonatomic) IBOutlet UIButton *tipValueBtn;

- (void)updateUI;

@end

@implementation TipViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    // Add Pan Gesture recognizer to the viewHandle
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    [self.viewHandle addGestureRecognizer:panGestureRecognizer];

    self.tipValueBtn.layer.cornerRadius = 6.0;
//    self.tipValueBtn.backgroundColor = [UIColor grayColor];
    [[self.tipValueBtn layer] setBorderWidth:1.6f];
    [[self.tipValueBtn layer] setBorderColor:[UIColor grayColor].CGColor];
    
    
    self.splitBtn.layer.cornerRadius = 6.0;
//    self.splitBtn.backgroundColor = [UIColor grayColor];
    [[self.splitBtn layer] setBorderWidth:1.4f];
    [[self.splitBtn layer] setBorderColor:[UIColor colorWithRed:118/255.0 green:181/255.0 blue:235/255.0 alpha:1.0].CGColor;
    
    
//    Adds shadow to Checkout View
    CALayer *layer = self.view.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.20f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    self.billAmount = 0;
    [self.billTextField becomeFirstResponder];
    self.billTextField.delegate = self;
    [self updateUI];
    
}
- (IBAction)tipValueChanged:(id)sender {
    NSArray *tipValues = @[@"0.15", @"0.18", @"0.2"];

    [self.tipValueBtn setTitle:[NSString stringWithFormat: @"%i%%", (int)(100 * [tipValues[self.tipControl.selectedSegmentIndex] floatValue])] forState: UIControlStateNormal];
    NSLog(@"%i%%", (int)(100 * [tipValues[self.tipControl.selectedSegmentIndex] floatValue]));

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    NSArray *tipValues = @[@"0.15", @"0.18", @"0.2"];
    
    float tipAmount = self.billAmount * [tipValues[self.tipControl.selectedSegmentIndex] floatValue];
    self.totalAmount = tipAmount + self.billAmount;
    
    self.tipLabel.text = [NSString stringWithFormat:@"$%0.2f", tipAmount];
    self.totalLabel.text = [NSString stringWithFormat:@"$%0.2f", self.totalAmount];

}

- (IBAction)onTap:(UISegmentedControl *)sender {
    [self updateUI];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    self.billAmount = [[self.billTextField.text stringByAppendingString:string] floatValue];
    
    [self updateUI];
    
    return YES;
}



- (IBAction)onTipValueBtn:(id)sender {
    TipSettingsViewController *tipSettingsVC = [[TipSettingsViewController alloc] init];
    [self presentViewController:tipSettingsVC animated:YES completion:nil];
}

- (IBAction)onSplitBtn:(id)sender {
    CheckSplitViewController *splitVC = [[CheckSplitViewController alloc] init];
    splitVC.amount = self.totalAmount;
    [self presentViewController:splitVC animated:YES completion:nil];
}

- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    CGPoint center;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.initialCenter = self.view.center;
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        self.view.center = CGPointMake(self.initialCenter.x, self.initialCenter.y + translation.y);
        
    } else if ( panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (velocity.y > 0){
            center = CGPointMake(self.initialCenter.x, 600);

        } else {
            center = CGPointMake(self.initialCenter.x, self.initialCenter.y);
        }
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:0 animations:^{
            self.view.center = center;
        } completion:^(BOOL finished) {
            if (velocity.y > 0){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        
    }
}


@end
