//
//  Bus.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "Bus.h"

@implementation Bus

@synthesize time;
@synthesize info;


- (id)initWithArrivalTime:(NSString *)aTime andInfo:(NSString *)aInfo {
    
    if (self = [super init]) {
        
        self.time = aTime;
        self.info = aInfo;
        
        return self;
    }
    
    return nil;
}

@end
