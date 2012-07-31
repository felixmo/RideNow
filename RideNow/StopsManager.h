//
//  StopsManager.h
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface StopsManager : NSObject

- (NSArray *)allStops;
- (NSArray *)stopsInRadius:(CGFloat)rad ofCoordinate:(CLLocationCoordinate2D)coord;

@end
