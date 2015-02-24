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
#import "FoodComposeViewController.h"
#import "RestaurantDetailViewController.h"
#import "CheckoutViewController.h"
#import "SettingsViewController.h"
#import "DishView.h"
#import "Restaurant.h"
#import "Dish.h"
#import "Parse/Parse.h"
#import "SearchViewController.h"

float const ANIMATION_DURATION = 0.5;
float const LIST_VIEW_EXPAND_BUFFER = 10;

@interface MainViewController () <SectionViewControllerDelegate, ListViewControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FoodComposeViewControllerDelegate, SearchViewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewYOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewXOffset;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) SectionViewController *svc;
@property (nonatomic, strong) ListViewController *lvc;
@property (weak, nonatomic) IBOutlet UIView *customNavBar;

@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, assign) NSNumber *isMenuOpen;

@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, strong) NSMutableArray *dishes;

@property (nonatomic, assign) CGPoint originalConstant;
@property (nonatomic, assign) CGFloat xCompliment;
@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) int animationType;



@end

@implementation MainViewController

typedef enum {
    ANIMATION_TYPE_BUBBLE,
    ANIMATION_TYPE_DOWNWARDEXPAND
} ANIMATION_TYPE;

- (void)viewWillAppear:(BOOL)animated {
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsViewController = [[SettingsViewController alloc] init];
    [self.view addSubview:self.settingsViewController.view];

    self.svc = [[SectionViewController alloc] init];
    self.svc.delegate = self;
    [self.svc setFrame:self.sectionView.frame];
    [self.view addSubview:self.svc.view];
    
    self.lvc = [[ListViewController alloc] init];
    self.lvc.delegate = self;
    [self.lvc setFrame:self.listView.frame];
    [self.view addSubview:self.lvc.view];

    [self.view bringSubviewToFront: self.customNavBar ];
    
    [self.view bringSubviewToFront:self.cameraButton];
    [self.view bringSubviewToFront:self.searchButton];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.svc.scrollView.panGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self.svc.view addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SectionViewControllerDelegate methods

- (void)swipeToRestaurant:(Restaurant *)restaurant {
    self.restaurant = restaurant;
    PFQuery *query = [PFQuery queryWithClassName:@"Food"];
    [query whereKey:@"restaurantId" equalTo:@"thai-square-restaurant-cupertino"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *dishes = [Dish dishWithDictionaries:objects];
        self.lvc.dishes = [NSMutableArray arrayWithArray:dishes];
    }];    
}

- (void)createFood:(PFObject *)food {
    
}

- (void)tapOnRestaurant:(Restaurant *)restaurant withGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([self.isMenuOpen isEqual:@1]) {
        [self closeMenu];
    } else {
        RestaurantDetailViewController *rdvc = [[RestaurantDetailViewController alloc] init];
        rdvc.restaurant = restaurant;
        rdvc.modalPresentationStyle = UIModalPresentationCustom;
        rdvc.transitioningDelegate = self;
        rdvc.view.frame = self.view.frame;
        [self presentViewController:rdvc animated:YES completion:nil];
    }
}

#pragma mark - ListViewControllerDelegate methods

- (void)tapOnDish:(int)page {
    if (self.lvc.expaned) {
        [self collapseListView];
    } else {
        [self expandListViewToPage:page];
    }
}

- (void)panOnDish:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // x-compliment to simulate scaling up while the horizontal center being the initial location of the gesture
        self.xCompliment = 2 * ([panGestureRecognizer locationInView:self.view].x / [[UIScreen mainScreen] bounds].size.width);
        self.originalConstant = CGPointMake(self.listViewXOffset.constant, self.listViewYOffset.constant);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = translation.y * 3;
        CGFloat deltaX = self.originalConstant.x + translation.x + scale * DISHVIEW_ASPECTRATIO * self.xCompliment;
        CGFloat deltaY = self.originalConstant.y + scale;
        
        if (deltaY > 0) {
            // over-compression can be performed at reduced rate
            deltaY /= 5;
            deltaX /= 5;
        }
        if (deltaX <= 0) {
            self.listViewXOffset.constant = deltaX;
        }
        if (deltaY <= 0) {
            self.listViewYOffset.constant = deltaY;
        }
        [self.lvc setFrame:self.listView.frame];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (translation.y < 0) {
            [self expandListView];
        } else {
            [self collapseListView];
        }
    }
}

- (void)expandListView {
    if (self.lvc.expaned) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat sectionWidth = self.lvc.view.frame.size.height * DISHVIEW_ASPECTRATIO;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        int page = floor((- self.listViewXOffset.constant - sectionWidth / 2 ) / sectionWidth) + 1;
        self.listViewXOffset.constant = - page * screenWidth;
        self.listViewYOffset.constant = - self.sectionView.frame.size.height;
        [self.view layoutIfNeeded];
        [self.lvc setFrame:self.listView.frame];
        
        self.lvc.scrollView.contentSize = CGSizeMake(self.lvc.dishes.count * screenWidth, screenHeight);
        self.lvc.scrollView.pagingEnabled = YES;
        
        self.lvc.pageControl.currentPage = page;
        self.lvc.expaned = YES;
    }];
}

- (void)expandListViewToPage:(int)page {
    if (self.lvc.expaned) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        self.listViewXOffset.constant = - page * screenWidth;
        self.listViewYOffset.constant = - self.sectionView.frame.size.height;
        [self.view layoutIfNeeded];
        [self.lvc setFrame:self.listView.frame];
        
        self.lvc.scrollView.contentSize = CGSizeMake(self.lvc.dishes.count * screenWidth, screenHeight);
        self.lvc.scrollView.pagingEnabled = YES;
        
        self.lvc.pageControl.currentPage = page;
        self.lvc.expaned = YES;
    }];
}

- (void)collapseListView {
    if (!self.lvc.expaned) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat sectionWidth = self.lvc.view.frame.size.height * DISHVIEW_ASPECTRATIO;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        self.listViewXOffset.constant = 0;
        self.listViewYOffset.constant = 0;
        [self.view layoutIfNeeded];
        [self.lvc setFrame:self.listView.frame];
        
        self.lvc.scrollView.contentSize = CGSizeMake(self.lvc.dishes.count * sectionWidth, screenHeight);
        self.lvc.scrollView.pagingEnabled = NO;
        self.lvc.expaned = NO;
    }];
}

#pragma mark - UIPanGestureRecognizerDelegate methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.svc.view];
    return fabs(velocity.y) > fabs(velocity.x);
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:[RestaurantDetailViewController class]]) {
        self.animationType = ANIMATION_TYPE_DOWNWARDEXPAND;
    } else {
        self.animationType = ANIMATION_TYPE_BUBBLE;
    }
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresenting = NO;
    [self.customNavBar setAlpha:1];
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (self.animationType) {
        case ANIMATION_TYPE_DOWNWARDEXPAND:
            [self tansitionInDownwardExpandForContext:transitionContext];
            break;
        case ANIMATION_TYPE_BUBBLE:
            [self tansitionInBubbleForContext:transitionContext];
            break;
        default:
            break;
    }
}

#pragma mark - Check Out

- (IBAction)onCheckoutButton:(id)sender {
    
    CheckoutViewController *checkoutVC = [[CheckoutViewController alloc] init];
    checkoutVC.modalPresentationStyle = UIModalPresentationCustom;
    checkoutVC.transitioningDelegate = self;
    
    [self presentViewController:checkoutVC animated:YES completion:^{
        [self.customNavBar setAlpha: 0];
    }];
}

#pragma mark - Add Food Item
- (IBAction)onSearchButton:(id)sender {
    SearchViewController *rdvc = [[SearchViewController alloc] init];
    rdvc.restaurants = self.svc.restaurants;
    rdvc.modalPresentationStyle = UIModalPresentationCustom;
    rdvc.transitioningDelegate = self;
    rdvc.delegate = self;
    rdvc.view.frame = self.view.frame;
    [self presentViewController:rdvc animated:YES completion:nil];
    
}

- (void) searchViewController:(SearchViewController *) searchViewController didSearchRestaurant:(NSMutableArray *)restaurants index:(NSInteger) index {
    [self.svc reloadDataForResult:restaurants atRestaurant:index];
}

- (IBAction)onCameraButton:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.transitioningDelegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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

#pragma mark - Settings View

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGFloat screenSize = self.view.frame.size.height - 40;
    CGFloat offset = ([self.isMenuOpen isEqual:@1]) ? (0 - screenSize) : 0;
    
    if ((translation.y >= (0 + offset)) && (translation.y <= (screenSize + offset))) {
        CGFloat newOffset = translation.y - offset;
        
        CGRect frame = self.svc.view.frame;
        frame.origin.y = newOffset;
        self.svc.view.frame = frame;
        
        CGRect lFrame = self.lvc.view.frame;
        lFrame.origin.y = newOffset + frame.size.height - 248.0;
        self.lvc.view.frame = lFrame;
        
        CGRect cFrame = self.cameraButton.frame;
        cFrame.origin.y = newOffset + 8.0;
        self.cameraButton.frame = cFrame;
        
        CGRect sFrame = self.searchButton.frame;
        sFrame.origin.y = newOffset + 8.0;
        self.searchButton.frame = sFrame;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [sender velocityInView:self.view];
        
        if (velocity.y > 0) {
            [self openMenu];
        } else if (velocity.y < 0) {
            [self closeMenu];
        }
    }
}

- (void)openMenu {
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat screenSize = self.view.frame.size.height - 40;

        CGRect frame = self.svc.view.frame;
        frame.origin.y = screenSize;
        self.svc.view.frame = frame;
        
        CGRect lFrame = self.lvc.view.frame;
        lFrame.origin.y = screenSize + frame.size.height - 248.0;
        self.lvc.view.frame = lFrame;
        
        CGRect cFrame = self.cameraButton.frame;
        cFrame.origin.y = screenSize + 8.0;
        self.cameraButton.frame = cFrame;

        CGRect sFrame = self.searchButton.frame;
        sFrame.origin.y = screenSize + 8.0;
        self.searchButton.frame = sFrame;
    }];
    
    self.isMenuOpen = @1;
}

- (void)closeMenu {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.svc.view.frame;
        frame.origin.y = 0;
        self.svc.view.frame = frame;
        
        CGRect lFrame = self.lvc.view.frame;
        lFrame.origin.y = frame.size.height - 248.0;
        self.lvc.view.frame = lFrame;
        
        CGRect cFrame = self.cameraButton.frame;
        cFrame.origin.y = 8.0;
        self.cameraButton.frame = cFrame;

        CGRect sFrame = self.searchButton.frame;
        sFrame.origin.y = 8.0;
        self.searchButton.frame = sFrame;
    }];
    
    self.isMenuOpen = 0;
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

@end
