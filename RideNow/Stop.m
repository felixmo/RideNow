//
//  Stop.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "Stop.h"

@implementation Stop

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize stopCode;

- (id)initAtCoordindate:(CLLocationCoordinate2D)coord withStopCode:(int)code {
    
    if (self = [super init]) {
        
        _coordinate = coord;
        stopCode = code;
        
        return self;
    }
    
    return nil;
}

- (NSString *)title {
    return [NSString stringWithFormat:@"#%i", stopCode];
}

@end
