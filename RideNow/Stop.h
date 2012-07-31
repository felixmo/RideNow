//
//  Stop.h
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Stop : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D _coordinate;
    NSString *_title;
    NSString *_subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, assign) int stopCode;

- (id)initAtCoordindate:(CLLocationCoordinate2D)coord withStopCode:(int)code;

@end
