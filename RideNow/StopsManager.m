//
//  StopsManager.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "StopsManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "Stop.h"
#import <CoreLocation/CoreLocation.h>


@interface StopsManager ()

@property (nonatomic, strong) FMDatabase *database;

@end

@implementation StopsManager

@synthesize database;


- (id)init {
    
    if (self = [super init]) {
        
        self.database = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"gtfs" ofType:@"db"]];
        if (![self.database open]) {
            NSLog(@"Could not open DB");
        }
        
        return self;
    }
    
    return nil;
}

- (NSArray *)allStops {
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    FMResultSet *resultSet = [self.database executeQuery:@"SELECT stop_lat,stop_lon,stop_code,stop_name,stop_desc FROM stops;"];

    while ([resultSet next]) {
        Stop *stop = [[Stop alloc] initAtCoordindate:CLLocationCoordinate2DMake([resultSet doubleForColumnIndex:0], [resultSet doubleForColumnIndex:1])
                                        withStopCode:[resultSet intForColumnIndex:2]];
        [stops addObject:stop];
    }
    
    return stops;
}

- (NSArray *)stopsInRadius:(CGFloat)rad ofCoordinate:(CLLocationCoordinate2D)coord {
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];

    NSString *query = [NSString stringWithFormat:@"SELECT stop_lat,stop_lon,stop_code,stop_name,stop_desc FROM stops WHERE stop_lat >= (%1.5f-%1.5f) AND stop_lat <= (%1.5f+%1.5f) AND stop_lon >= (%1.5f-%1.5f) AND stop_lon <= (%1.5f+%1.5f);", coord.latitude, rad, coord.latitude, rad, coord.longitude, rad, coord.longitude, rad];
    
    FMResultSet *resultSet = [self.database executeQuery:query];
    
//    if ([self.database hadError]) {
//        NSLog(@"DB Error %d: %@", [self.database lastErrorCode], [self.database lastErrorMessage]);
//    }
        
    while ([resultSet next]) {
        Stop *stop = [[Stop alloc] initAtCoordindate:CLLocationCoordinate2DMake([resultSet doubleForColumnIndex:0], [resultSet doubleForColumnIndex:1])
                                        withStopCode:[resultSet intForColumnIndex:2]];
        [stops addObject:stop];
    }
        
    return stops;
}

@end
