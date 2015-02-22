//
//  DishDetailViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/21/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "DishDetailViewController.h"

@interface DishDetailViewController ()

@end

@implementation DishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // handle tap gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture methods

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
