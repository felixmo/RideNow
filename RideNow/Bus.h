//
//  Bus.h
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bus : NSObject

- (id)initWithArrivalTime:(NSString *)time andInfo:(NSString *)info;

@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *info;

@end
