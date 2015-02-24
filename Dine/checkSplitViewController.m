//
//  checkSplitViewController.m
//  Dine
//
//  Created by Fabián Uribe Herrera on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "CheckSplitViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CheckSplitViewController () <UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic, assign) float splitAmount;

@end

@implementation CheckSplitViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
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



- (IBAction)onRequestBtn:(id)sender {
    
    NSString *recipientEmail = @"fabian.uribe@gmail.com";
    NSString *serviceEmail = @"request@square.com";
    
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?cc=%@&subject=$%.02f",recipientEmail, serviceEmail, self.splitAmount];
    
    NSString *body = [NSString stringWithFormat:@"&body=Please send $%0.2f to cover your share of the total bill ($%0.2f) from %@", self.splitAmount, self.amount, self.restaurant.name];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)onSentBtn:(id)sender {
    
    NSString *recipientEmail = @"fabian.uribe@gmail.com";
    NSString *serviceEmail = @"cash@square.com";
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:%@?cc=%@&subject=$%.02f",recipientEmail, serviceEmail, self.splitAmount];
    
    NSString *body = [NSString stringWithFormat:@"&body=Here is my share of $%0.2f to cover the bill ($%0.2f) from %@", self.splitAmount, self.amount, self.restaurant.name];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}



- (IBAction)onContactsBtn:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)displayPerson:(ABRecordRef)person {

    NSString* email = nil;
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    if ( emails && ABMultiValueGetCount(emails) > 0) {
        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, 0);
    } else {
        email = @" - contact has no email - ";
    }
    self.emailTextField.text = email;
}


- (IBAction)onDoneBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
