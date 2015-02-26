//
//  SettingsViewController.m
//  Dine
//
//  Created by Matt Ho on 2/22/15.
//  Copyright (c) 2015 Yahoo!, inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "Parse/Parse.h"
#import "SettingCell.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CAGradientLayer *gradientView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    self.gradientView = [CAGradientLayer layer];
    self.gradientView.frame = self.tableView.frame;
    self.gradientView.colors = [NSArray arrayWithObjects:(id)[[UIColor purpleColor] CGColor], (id)[[UIColor blueColor] CGColor], nil];
    self.tableView.autoresizesSubviews = YES;
    [self.tableView.layer insertSublayer:self.gradientView atIndex:0];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.gradientView.frame = self.tableView.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    if (indexPath.row == 0) {
        PFUser *user = [PFUser currentUser];
        cell.name = user[@"fullname"];
        cell.iconImageUrl = user[@"profileImageUrl"];
    } else {
        cell.iconImage = [UIImage imageNamed:@"logout.png"];
        cell.name = @"Logout";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
