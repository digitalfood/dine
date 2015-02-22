//
//  FoodComposeViewController.m
//  Dine
//
//  Created by Matt Ho on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "FoodComposeViewController.h"
#import "Parse/Parse.h"

@interface FoodComposeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *commentsField;
@property (weak, nonatomic) IBOutlet UIButton *starButton1;
@property (weak, nonatomic) IBOutlet UIButton *starButton2;
@property (weak, nonatomic) IBOutlet UIButton *starButton3;
@property (weak, nonatomic) IBOutlet UIButton *starButton4;
@property (weak, nonatomic) IBOutlet UIButton *starButton5;
@property (nonatomic, strong) NSArray *buttonList;

@end

@implementation FoodComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize variables
    self.buttonList = @[self.starButton1, self.starButton2, self.starButton3, self.starButton4, self.starButton5];
    self.thumbnailImageView.image = self.thumbnailImage;
    
    // Setup navigation items
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSaveButton)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onSaveButton {
    UIButton *button;
    NSNumber *ratings = 0;
    BOOL selected = YES;
    
    for (NSInteger i = 0; i < self.buttonList.count && selected == YES; i++) {
        button = self.buttonList[i];
        if (button.selected) {
            ratings = [[NSNumber alloc] initWithLong:i];
        } else {
            selected = NO;
        }
    }
    
    PFObject *food = [PFObject objectWithClassName:@"Food"];
    food[@"name"] = self.nameField.text;
    food[@"comments"] = self.commentsField.text;
    food[@"ratings"] = ratings;
    food[@"restaurantId"] = self.restaurant.id;
    
    NSData *imageData = UIImagePNGRepresentation(self.thumbnailImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    food[@"thumbnail"] = imageFile;
    
    [food saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate createFood:food];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


#pragma mark - Ratings

- (IBAction)onStarButton1:(id)sender {
    [self selectRating:0];
}

- (IBAction)onStarButton2:(id)sender {
    [self selectRating:1];
}

- (IBAction)onStarButton3:(id)sender {
    [self selectRating:2];
}

- (IBAction)onStarButton4:(id)sender {
    [self selectRating:3];
}

- (IBAction)onStarButton5:(id)sender {
    [self selectRating:4];
}

- (void)selectRating:(NSInteger)rating {
    UIButton *button;
    
    for (NSInteger i = 0; i < self.buttonList.count; i++) {
        button = self.buttonList[i];
        
        if (i == rating) {
            NSInteger next = i + 1;
            
            if (next < self.buttonList.count) {
                UIButton *nextButton = self.buttonList[next];
                button.selected = nextButton.selected || !button.selected;
            } else {
                button.selected = !button.selected;
            }
        } else {
            button.selected = (i < rating);
        }
    }
    
    
}

@end
