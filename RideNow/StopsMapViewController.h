//
//  StopsMapViewController.h
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol StopsMapViewControllerDelegate
@optional

- (void)didSelectStopWithStopCode:(int)code;

@end

@interface StopsMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, unsafe_unretained) id <StopsMapViewControllerDelegate> delegate;

@end
