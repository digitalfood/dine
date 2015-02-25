//
//  TipViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/12/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CheckoutViewController.h"
#import "CheckSplitViewController.h"
#import "TipSettingsViewController.h"

@interface CheckoutViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UIView *viewHandle;
@property (weak, nonatomic) IBOutlet UIButton *splitBtn;
@property (weak, nonatomic) IBOutlet UIButton *tipValueBtn;

@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, assign) float totalAmount;
@property (nonatomic, assign) double billAmount;
@property (weak, nonatomic) IBOutlet UIView *checkView;

- (void)updateUI;

@end

@implementation CheckoutViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Add Pan Gesture recognizer to the viewHandle
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    [self.viewHandle addGestureRecognizer:panGestureRecognizer];
    
    // Adds shadow to Checkout View
    CALayer *layer = self.checkView.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 6.0f;
    layer.shadowOpacity = 0.40f;
    layer.shadowOffset = CGSizeMake(0, 12.0);
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    self.billAmount = 0;
    self.billTextField.delegate = self;
    [self updateUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.billTextField becomeFirstResponder];

}


- (IBAction)tipValueChanged:(id)sender {
    NSArray *tipValues = @[@"0.15", @"0.18", @"0.2"];

    [self.tipValueBtn setTitle:[NSString stringWithFormat: @"%i%%", (int)(100 * [tipValues[self.tipControl.selectedSegmentIndex] floatValue])] forState: UIControlStateNormal];
    NSLog(@"%i%%", (int)(100 * [tipValues[self.tipControl.selectedSegmentIndex] floatValue]));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
            center = CGPointMake(self.initialCenter.x, self.view.frame.size.height*1.5);

        } else {
            center = CGPointMake(self.initialCenter.x, self.initialCenter.y);
        }
        
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:0 animations:^{
            self.view.center = center;
        } completion:^(BOOL finished) {
            if (velocity.y > 0){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}


@end
