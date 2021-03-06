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

@interface MainViewController () <SectionViewControllerDelegate, ListViewControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FoodComposeViewControllerDelegate, SearchViewControllerDelegate, UIGestureRecognizerDelegate, CheckoutViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listViewYOffset;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) SectionViewController *svc;
@property (nonatomic, strong) ListViewController *lvc;
@property (weak, nonatomic) IBOutlet UIView *customNavBar;

@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, assign) NSNumber *isMenuOpen;

@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, strong) NSMutableArray *dishes;

@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, assign) CGPoint originalXY;
@property (nonatomic, assign) CGFloat touchLocationX;
@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, assign) int animationType;

@property (nonatomic, strong) NSString *searchTerm;

@end

@implementation MainViewController

typedef enum {
    ANIMATION_TYPE_FADEIN,
    ANIMATION_TYPE_BUBBLE,
    ANIMATION_TYPE_DOWNWARDEXPAND,
    AMIATION_TYPE_FROMBELOW
} ANIMATION_TYPE;

- (void)viewWillAppear:(BOOL)animated {
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    [self.view setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsViewController = [[SettingsViewController alloc] init];
    self.settingsViewController.view.alpha = 0;
    [self.view addSubview:self.settingsViewController.view];

    self.svc = [[SectionViewController alloc] init];
    self.svc.delegate = self;
    self.svc.searchTerm = self.searchTerm;
    [self.svc setFrame:self.sectionView.frame];
    [self.view addSubview:self.svc.view];
    
    self.lvc = [[ListViewController alloc] init];
    self.lvc.delegate = self;
    [self.lvc setFrame:self.listView.frame preLayout:NO];
    [self.view addSubview:self.lvc.view];

    [self.view bringSubviewToFront: self.customNavBar ];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.svc.scrollView.panGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self.svc.view addGestureRecognizer:panGestureRecognizer];
    
    // handle cuntomNavBar gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.customNavBar addGestureRecognizer:tapGestureRecognizer];

    UIPanGestureRecognizer *navBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self.customNavBar addGestureRecognizer:navBarPanGestureRecognizer];
    
    self.customNavBar.userInteractionEnabled = YES;
    
    self.searchTerm = @"Restaurants";
}

#pragma mark - onTap methods
- (IBAction)onTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self tapOnRestaurant:self.restaurant withGesture:tapGestureRecognizer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SectionViewControllerDelegate methods

- (void)swipeToRestaurant:(Restaurant *)restaurant rtl:(BOOL)rtl {
    self.restaurant = restaurant;
    NSString *restaurantId;
    NSArray *whilteList = @[@"gochi-japanese-fusion-tapas-cupertino", @"ikes-lair-cupertino-2", @"dish-n-dash-sunnyvale", @"gombei-bento-sunnyvale"];
    // THIS IS A TEMPORARY HACK TO SHOW DEFAULT DISHES WHEN THERE'S NO DISHES IN PARSE
    if ([whilteList containsObject:restaurant.id]) {
        restaurantId = restaurant.id;
    } else {
        restaurantId = @"thai-square-restaurant-cupertino";
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Food"];
    [query whereKey:@"restaurantId" equalTo:restaurantId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *dishes = [Dish dishWithDictionaries:objects];
        self.lvc.reverseSliding = !rtl; // reverse sliding-in animation if not swiped from right to left
        self.lvc.dishes = [NSMutableArray arrayWithArray:dishes];
    }];    
}

- (void)createFood:(PFObject *)food {
    NSMutableArray *foods = [NSMutableArray arrayWithArray:self.lvc.dishes];
    [foods insertObject:[Dish dishWithPFObject:food] atIndex:0];
    self.lvc.reverseSliding = YES;
    [self.lvc setDishes:foods];
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

- (void)panOnDish:(int)page withRecognier:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.touchLocationX = [panGestureRecognizer locationInView:self.view].x;
        self.originalXY = CGPointMake(self.lvc.scrollView.contentOffset.x, self.listViewYOffset.constant);
        self.originalHeight = self.lvc.scrollView.frame.size.height;
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat yDistance = translation.y * 3;
        CGFloat deltaY = self.originalXY.y + yDistance;
        CGFloat newHeight = self.originalHeight - deltaY;
        CGFloat scale = newHeight / self.originalHeight;
        CGFloat deltaX =  -translation.x + (self.originalXY.x + self.touchLocationX) * scale - self.touchLocationX;
        self.lvc.scrollView.contentOffset = CGPointMake(deltaX, 0);
        if (deltaY <= 0) {
            self.listViewYOffset.constant = deltaY;
        }
        [self.lvc setFrame:self.listView.frame preLayout:NO];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([panGestureRecognizer velocityInView:self.view].y < 0) {
            [self expandListViewToPage:page];
        } else {
            [self collapseListView];
        }
    }
}

- (void)expandListViewToPage:(int)page {
    self.customNavBar.alpha = 1;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.lvc.scrollView.pagingEnabled = YES;
    self.lvc.expaned = YES;
    self.listViewYOffset.constant = - self.sectionView.frame.size.height;
    self.lvc.pageControl.currentPage = page;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.customNavBar.alpha = 0;
        self.lvc.scrollView.contentOffset = CGPointMake(page * screenWidth, 0);
        [self.lvc setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) preLayout:NO];
    }];
}

- (void)collapseListView {
    self.customNavBar.alpha = 0;
    self.lvc.scrollView.pagingEnabled = NO;
    self.lvc.expaned = NO;
    self.listViewYOffset.constant = 0;
    [self.view layoutIfNeeded];
    CGFloat sectionHeight = self.listView.frame.size.height;
    CGFloat scale = sectionHeight / [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.customNavBar.alpha = 1;
        self.lvc.scrollView.contentOffset = CGPointMake(self.lvc.scrollView.contentOffset.x * scale, 0);
        [self.lvc setFrame:self.listView.frame preLayout:YES];
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
        self.animationType = ANIMATION_TYPE_FADEIN;
    } else if([presented isKindOfClass:[SearchViewController class]]) {
        self.animationType = ANIMATION_TYPE_BUBBLE;
    } else {
        self.animationType = AMIATION_TYPE_FROMBELOW;
    }
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresenting = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self.customNavBar setAlpha: 1];
    }];
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return ANIMATION_DURATION;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    switch (self.animationType) {
        case ANIMATION_TYPE_FADEIN:
            [self tansitionFadeInContext:transitionContext];
            break;
        case ANIMATION_TYPE_DOWNWARDEXPAND:
            [self tansitionInDownwardExpandForContext:transitionContext];
            break;
        case ANIMATION_TYPE_BUBBLE:
            [self tansitionInBubbleForContext:transitionContext];
            break;
        default:
            [self transitionFromBelow:transitionContext];
            break;
    }
}

#pragma mark - Check Out

- (IBAction)onCheckoutButton:(id)sender {
    
    CheckoutViewController *checkoutVC = [[CheckoutViewController alloc] init];
    checkoutVC.modalPresentationStyle = UIModalPresentationCustom;
    checkoutVC.transitioningDelegate = self;
    checkoutVC.delegate = self;
    [self.svc hideRestaurantName:YES];
    [UIView animateWithDuration:0.5 animations:^{
        [self.customNavBar setAlpha: 0];
    }];
    [self presentViewController:checkoutVC animated:YES completion:nil];
}

- (void) checkoutViewController:(SearchViewController *) checkoutViewController hideText:(BOOL)hide {
    
    [self.svc hideRestaurantName:hide];
    
}

#pragma mark - Add Food Item
- (IBAction)onSearchButton:(id)sender {
    SearchViewController *rdvc = [[SearchViewController alloc] init];
    rdvc.restaurants = self.svc.restaurants;
    rdvc.modalPresentationStyle = UIModalPresentationCustom;
    rdvc.transitioningDelegate = self;
    rdvc.delegate = self;
    rdvc.searchTerm = self.searchTerm;
    rdvc.view.frame = self.view.frame;
    [self.svc hideRestaurantName:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.customNavBar setAlpha: 0];
    }];
    
    [self presentViewController:rdvc animated:YES completion:nil];
    
}

- (void) searchViewController:(SearchViewController *) searchViewController didSearchRestaurant:(NSMutableArray *)restaurants index:(NSInteger) index searchTerm: (NSString*) searchTerm; {
    self.searchTerm = searchTerm;
    self.svc.searchTerm = self.searchTerm;
    [self.svc reloadDataForResult:restaurants atRestaurant:index];
}

- (void) searchViewController:(SearchViewController *) searchViewController hideText:(BOOL)hide {
    
    [self.svc hideRestaurantName:hide];
    
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
        
        CGRect cFrame = self.customNavBar.frame;
        cFrame.origin.y = newOffset;
        self.customNavBar.frame = cFrame;
        
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
    self.settingsViewController.view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.settingsViewController.view.alpha = 1;
        CGFloat screenSize = self.view.frame.size.height - 40;

        CGRect frame = self.svc.view.frame;
        frame.origin.y = screenSize;
        self.svc.view.frame = frame;
        
        CGRect lFrame = self.lvc.view.frame;
        lFrame.origin.y = screenSize + frame.size.height - 248.0;
        self.lvc.view.frame = lFrame;
        
        CGRect cFrame = self.customNavBar.frame;
        cFrame.origin.y = screenSize;
        self.customNavBar.frame = cFrame;

    }];
    
    self.isMenuOpen = @1;
}

- (void)closeMenu {
    self.settingsViewController.view.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.settingsViewController.view.alpha = 0;
        CGRect frame = self.svc.view.frame;
        frame.origin.y = 0;
        self.svc.view.frame = frame;
        
        CGRect lFrame = self.lvc.view.frame;
        lFrame.origin.y = frame.size.height - 248.0;
        self.lvc.view.frame = lFrame;
        
        CGRect cFrame = self.customNavBar.frame;
        cFrame.origin.y = 0;
        self.customNavBar.frame = cFrame;

    }];
    
    self.isMenuOpen = @0;
}

#pragma mark - private methods

- (void)tansitionInBubbleForContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
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

- (void)tansitionFadeInContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresenting) {
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
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

- (void)transitionFromBelow:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresenting) {
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 1;
        CGRect frame = self.view.frame;
        frame.origin.y = self.view.frame.size.height;
        toViewController.view.frame = frame;
        
        
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:4 options:0 animations:^{
            
            toViewController.view.alpha = 1;
            CGRect frame = self.view.frame;
            toViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        fromViewController.view.alpha = 1;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            toViewController.view.alpha = 1;
            CGRect frame = self.view.frame;
            toViewController.view.frame = frame;
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
