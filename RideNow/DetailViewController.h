//
//  DetailViewController.h
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController

- (id)initWithStop:(int)aStop andTime:(NSDate *)aTime;

@end
