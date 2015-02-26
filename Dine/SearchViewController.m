//
//  SearchViewController.m
//  Dine
//
//  Created by Joanna Chan on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SearchViewController.h"
#import "YelpClient.h"
#import "SearchCell.h"
#import "LocationManager.h"

@interface SearchViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHandle;
@property (nonatomic, assign) CGPoint initialCenter;

@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) YelpClient *client;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplay;

@property (nonatomic, assign) BOOL isInRefresh;
@property (nonatomic, strong) NSNumber *offset;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.client = [YelpClient sharedInstance];
    self.locationManager = [LocationManager sharedInstance];
    self.location = self.locationManager.location;
    
    [self.searchDisplay setDelegate:self];
    [self.searchDisplay setSearchResultsDataSource:self];
    [self.searchBar setShowsCancelButton:NO animated:NO];
    [self.searchDisplay.searchBar setShowsCancelButton:NO animated:NO];
    
    self.searchDisplay.searchResultsTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.searchDisplay.searchResultsTableView reloadData];
    self.title = @"Search";
    
    // Add Pan Gesture recognizer to the viewHandle
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    [self.viewHandle addGestureRecognizer:panGestureRecognizer];
    
    self.isInRefresh = NO;
    self.offset = 0;
    
    self.restaurants = [NSMutableArray array];
    
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
    self.searchBar.text = self.searchTerm;
    [self.searchDisplay.searchResultsTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restaurants.count;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:@"SearchCell"];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue or create a cell of the appropriate type.
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    cell.restaurant = self.restaurants[indexPath.row];
    
    if (indexPath.row == self.restaurants.count - 1 && !self.isInRefresh) {
        tableView.tableFooterView.hidden = NO;
        self.isInRefresh = YES;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        self.offset = [NSNumber numberWithLong:self.restaurants.count];
        [params setValue:self.offset forKey:@"offset"];
        NSLog(@"offset %@", self.offset);
        [self fetchBusinessWithTerm:self.searchTerm params:params];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    [self.delegate searchViewController:self didSearchRestaurant:self.restaurants index:indexPath.row searchTerm:self.searchTerm];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"shouldReloadTableForSearchString");
    self.searchTerm = searchString;
    self.offset = 0;
    if(![searchString isEqual: @""]){
        
        [self fetchBusinessWithTerm:searchString params:nil];
        
    }
    
    return YES;
}

- (void)fetchBusinessWithTerm:(NSString *)term params:(NSMutableDictionary *)params {
    
    if(params == nil){
        params = [NSMutableDictionary dictionary];
    }
    
    if (self.location != nil) {
        
        NSString *currentLocation = [NSString stringWithFormat:@"%+.6f,%+.6f",self.location.coordinate.latitude, self.location.coordinate.longitude];
        [params setObject:currentLocation forKey:@"ll"];
        
        [self.client searchWithTerm:term params:params success:^(AFHTTPRequestOperation *operation, id response) {
            NSArray *restaurantsDictionary = response[@"businesses"];
            NSArray *restaurants = [Restaurant restaurantsWithDictionaries:restaurantsDictionary];
            [self.restaurants addObjectsFromArray:restaurants];
            [self.searchDisplay.searchResultsTableView reloadData];
            
            self.searchDisplay.searchResultsTableView.tableFooterView.hidden = YES;
            self.isInRefresh = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [error description]);
        }];
    }
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    controller.searchBar.showsCancelButton = NO;
    NSLog(@"searchDisplayControllerDidBeginSearch");
    
}


- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.searchBar endEditing:YES];
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    CGPoint center;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.initialCenter = self.view.center;
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        if(translation.y > 40){
            [self.delegate searchViewController:self hideText:NO];
        }else{
            [self.delegate searchViewController:self hideText:YES];
        }
        self.view.center = CGPointMake(self.initialCenter.x, self.initialCenter.y + translation.y);
        
    } else if ( panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (velocity.y > 0){
            center = CGPointMake(self.initialCenter.x, 600);
            
        } else {
            center = CGPointMake(self.initialCenter.x, self.initialCenter.y);
        }
        
            if (velocity.y > 0){
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate searchViewController:self hideText:NO];
            }else{
                
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:0 animations:^{
                    self.view.center = center;
                } completion:^(BOOL finished) {
                    [self.delegate searchViewController:self hideText:YES];
                }];
            }
        
        
    }
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
