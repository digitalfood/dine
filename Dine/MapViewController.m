//
//  MapViewController.m
//  Yelp
//
//  Created by Pythis Ting on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "MapViewController.h"
#import "LocationManager.h"

#ifndef METERS_PER_MILE
#define METERS_PER_MILE 1609.344
#endif

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, strong) CLLocation* location;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton)];
    
    // init location
    self.locationManager = [LocationManager sharedInstance];
    self.location = self.locationManager.location;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.location.coordinate.latitude, self.location.coordinate.longitude), 2 * METERS_PER_MILE, 2 * METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    self.mapView.delegate = self;
    
    [self plotPositions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plotPositions {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    [self.mapView addAnnotation:self.restaurant];
}

#pragma mark - MKMapViewDelegate methods
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *annotationView;
    for (annotationView in views) {
        if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
            annotationView.canShowCallout = NO;
        } else {
            annotationView.canShowCallout = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Restaurant *restaurant = (Restaurant*) view.annotation;
    
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [restaurant.mapItem openInMapsWithLaunchOptions:launchOptions];
}

#pragma mark - Private methods
- (void)onBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
