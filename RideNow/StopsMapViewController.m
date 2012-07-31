//
//  StopsMapViewController.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "StopsMapViewController.h"
#import "StopsManager.h"
#import "Stop.h"
#import "MBProgressHUD.h"

@interface StopsMapViewController ()

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) StopsManager *stopsManager;
@property (nonatomic, assign) BOOL didShowLocation;

@end

@implementation StopsMapViewController

@synthesize mapView;
@synthesize stopsManager;
@synthesize delegate;
@synthesize didShowLocation;

- (void)dealloc {
    
    delegate = nil;
    
    
}

- (id)init {
    
    if (self = [super init]) {
        
        self.stopsManager = [[StopsManager alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Stops";
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.view.bounds.size.height-44.0f)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self.view addSubview:self.mapView];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeBtn;
    
    if (self.mapView.centerCoordinate.latitude != self.mapView.userLocation.coordinate.latitude ||
        self.mapView.centerCoordinate.longitude != self.mapView.userLocation.coordinate.longitude) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [hud setTag:9];
        [hud setDimBackground:YES];
        [hud setAnimationType:MBProgressHUDAnimationZoom];
        [self.view addSubview:hud];
        [hud show:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)close {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - MKMapView delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!didShowLocation) {
                
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.005;
        mapRegion.span.longitudeDelta = 0.005;
        
        [self.mapView setRegion:mapRegion animated:YES];
        
        didShowLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
    MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:9];
    if (hud) {
        [hud hide:YES];
        [hud removeFromSuperview];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSMutableArray *remove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations copyItems:NO];
    [remove removeObject:self.mapView.userLocation];    
    [self.mapView removeAnnotations:remove];
    
    if (self.mapView.region.span.latitudeDelta <= 0.05) {
        
        [self.mapView addAnnotations:[self.stopsManager stopsInRadius:self.mapView.region.span.latitudeDelta/2 ofCoordinate:self.mapView.centerCoordinate]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if (annotation != self.mapView.userLocation) {
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }

        pinView.annotation = annotation;
        
        return pinView;
    }
    else {
        MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:9];
        if (hud) {
            [hud hide:YES];
            [hud removeFromSuperview];
        }
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [delegate didSelectStopWithStopCode:[(Stop *)[view annotation] stopCode]];
    [self close];
}

@end
