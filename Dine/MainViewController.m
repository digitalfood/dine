//
//  MainViewController.m
//  Dine
//
//  Created by Pythis Ting on 2/17/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "MainViewController.h"
#import "SectionViewController.h"
#import "ListViewController.h"
#import "DishDetailViewController.h"
#import "FoodComposeViewController.h"
#import "RestaurantDetailViewController.h"
#import "DishView.h"
#import "Restaurant.h"
#import "Parse/Parse.h"

float const ANIMATION_DURATION = 0.5;

@interface MainViewController () <SectionViewControllerDelegate, ListViewControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FoodComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet UIView *listView;

@property (nonatomic, strong) SectionViewController *svc;
@property (nonatomic, strong) ListViewController *lvc;
@property (nonatomic, strong) DishDetailViewController *ddvc;

@property (nonatomic, strong) Restaurant *restaurant;

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) int animationType;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, assign) BOOL disableInteractiveTransition;

@end

@implementation MainViewController

typedef enum {
    ANIMATION_TYPE_BUBBLE,
    ANIMATION_TYPE_DOWNWARDEXPAND,
    ANIMATION_TYPE_UPWARDEXPAND
} ANIMATION_TYPE;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.svc = [[SectionViewController alloc] init];
    self.svc.delegate = self;
    self.svc.view.frame = self.sectionView.frame;
    [self.view addSubview:self.svc.view];
    
    self.lvc = [[ListViewController alloc] init];
    self.lvc.delegate = self;
    self.lvc.view.frame = self.listView.frame;
    [self.view addSubview:self.lvc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SectionViewControllerDelegate methods

- (void)swipeToRestaurant:(Restaurant *)restaurant {
    NSLog(@"swiped to : %@", restaurant.name);
    
    self.restaurant = restaurant;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Food"];
    [query whereKey:@"restaurantId" equalTo:@"restaurant-3000-menlo-park"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *food in objects) {
            NSLog(@"%@", food);
        }
    }];
    
}

- (void)createFood:(PFObject *)food {
    // Joanna please update food menu accordingly
}


- (void)tapOnRestaurant:(Restaurant *)restaurant withGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.disableInteractiveTransition = YES;
    RestaurantDetailViewController *rdvc = [[RestaurantDetailViewController alloc] init];
    rdvc.restaurant = restaurant;
    rdvc.modalPresentationStyle = UIModalPresentationCustom;
    rdvc.transitioningDelegate = self;
    [self presentViewController:rdvc animated:YES completion:nil];
}

#pragma mark - ListViewControllerDelegate methods

- (void)tapOnDish {
    self.disableInteractiveTransition = YES;
    DishDetailViewController *ddvc = [[DishDetailViewController alloc] init];
    ddvc.modalPresentationStyle = UIModalPresentationCustom;
    ddvc.transitioningDelegate = self;;
    [self presentViewController:ddvc animated:YES completion:nil];
}

- (void)panOnDish:(UIPanGestureRecognizer *)panGestureRecognizer {
    self.disableInteractiveTransition = NO;
    CGPoint translation = [panGestureRecognizer translationInView:self.listView];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.listView];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.ddvc = [[DishDetailViewController alloc] init];
        self.ddvc.modalPresentationStyle = UIModalPresentationCustom;
        self.ddvc.transitioningDelegate = self;
        [self presentViewController:self.ddvc animated:YES completion:nil];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = - translation.y / 50;
        NSLog(@"progress: %f", progress);
        [self.interactiveTransition updateInteractiveTransition:progress];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.y < 0) {
            [self.interactiveTransition finishInteractiveTransition];
        } else {
            [self.interactiveTransition cancelInteractiveTransition];
            [self.ddvc dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[RestaurantDetailViewController class]]) {
        self.animationType = ANIMATION_TYPE_DOWNWARDEXPAND;
    } else if ([presented isKindOfClass:[DishDetailViewController class]]) {
        self.animationType = ANIMATION_TYPE_UPWARDEXPAND;
    } else {
        self.animationType = ANIMATION_TYPE_BUBBLE;
    }
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresenting = NO;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    if (self.disableInteractiveTransition) {
        return nil;
    }
    self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
    self.interactiveTransition.completionSpeed = 0.99;
    return self.interactiveTransition;
}

//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
//    
//}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (self.animationType) {
        case ANIMATION_TYPE_DOWNWARDEXPAND:
            [self tansitionInDownwardExpandForContext:transitionContext];
            break;
        case ANIMATION_TYPE_UPWARDEXPAND:
            [self tansitionInUpwardExpandForContext:transitionContext];
            break;
        case ANIMATION_TYPE_BUBBLE:
            [self tansitionInBubbleForContext:transitionContext];
            break;
        default:
            break;
    }
}

#pragma mark - Add Food Item

- (IBAction)onCameraButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    FoodComposeViewController *vc = [[FoodComposeViewController alloc] init];
    vc.delegate = self;
    vc.thumbnailImage = info[UIImagePickerControllerOriginalImage];
    vc.restaurant = self.restaurant;

    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:nvc animated:YES completion:nil];
    }];
}

#pragma mark - private methods

- (void)tansitionInBubbleForContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Fabio you can use this function for rendering tip calculator
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if (self.isPresenting) {
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        toViewController.view.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        fromViewController.view.alpha = 1;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            fromViewController.view.alpha = 0;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
        }];
    }
}

- (void)tansitionInDownwardExpandForContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresenting) {
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        fromViewController.view.alpha = 1;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            fromViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
        }];
    }
}

- (void)tansitionInUpwardExpandForContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGFloat yRatio = self.sectionView.frame.size.height / [[UIScreen mainScreen] bounds].size.height;
    
    if (self.isPresenting) {
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        toViewController.view.center = CGPointMake(toViewController.view.center.x, self.sectionView.frame.size.height / 2);
        toViewController.view.transform = CGAffineTransformMakeScale(1, yRatio);
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            toViewController.view.center = CGPointMake(toViewController.view.center.x, [[UIScreen mainScreen] bounds].size.height / 2);
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        fromViewController.view.alpha = 1;
        fromViewController.view.center = CGPointMake(toViewController.view.center.x, [[UIScreen mainScreen] bounds].size.height / 2);
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            fromViewController.view.center = CGPointMake(toViewController.view.center.x, self.sectionView.frame.size.height / 2);
            fromViewController.view.alpha = 0;
            fromViewController.view.transform = CGAffineTransformMakeScale(1, yRatio);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [fromViewController.view removeFromSuperview];
        }];
    }
}

@end
