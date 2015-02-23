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

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic, strong) YelpClient *client;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplay;

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
    
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
    self.searchBar.text = @"Restaurants";
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    [self.delegate searchViewController:self didSearchRestaurant:self.restaurants index:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"shouldReloadTableForSearchString");
    
    if(![searchString  isEqual: @""]){
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (self.location != nil) {
            NSString *currentLocation = [NSString stringWithFormat:@"%+.6f,%+.6f",self.location.coordinate.latitude, self.location.coordinate.longitude];
            [params setObject:currentLocation forKey:@"ll"];
            
            [self.client searchWithTerm:searchString params:params success:^(AFHTTPRequestOperation *operation, id response) {
                NSArray *restaurantsDictionary = response[@"businesses"];
                NSArray *restaurants = [Restaurant restaurantsWithDictionaries:restaurantsDictionary];
                self.restaurants = [NSMutableArray arrayWithArray:restaurants];
                [controller.searchResultsTableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", [error description]);
            }];
        }
    }
    
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    controller.searchBar.showsCancelButton = NO;
    NSLog(@"searchDisplayControllerDidBeginSearch");
    
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
