//
//  DetailViewController.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "DetailViewController.h"
#import "TFHpple.h"
#import "Bus.h"
#import "AFNetworking.h"
#import "NSDate-Utilities.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"


@interface DetailViewController ()

@property (nonatomic, assign) int stop;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSMutableDictionary *buses;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, unsafe_unretained) AFHTTPRequestOperation *activeOp;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSString *errorMessage;

@end

@implementation DetailViewController

@synthesize stop;
@synthesize time;
@synthesize buses;
@synthesize dateFormatter;
@synthesize activeOp;
@synthesize timeoutTimer;
@synthesize errorMessage;


- (id)initWithStop:(int)aStop andTime:(NSDate *)aTime {
    
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.buses = [[NSMutableDictionary alloc] init];
        stop = aStop;
        self.time = aTime;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Next buses";
    
    [self.dateFormatter setDateFormat:@"MM-dd-YYYY"];
    NSString *date = [self.dateFormatter stringFromDate:self.time];
    
    [self.dateFormatter setDateFormat:@"a"];
    NSString *meridiem = [[[self.dateFormatter stringFromDate:self.time] substringToIndex:1] lowercaseString];
    
    NSString *requestURL = [NSString stringWithFormat:@"http://tripplanner.yrt.ca/hiwire?Date=%@&TimeHour=%i&TimeMinute=%i&Meridiem=%@&.a=iNextBusFind&.s=995feb08&ShowTimes=1&NumStopTimes=5&GetSchedules=1&EndGeo=&StopAbbr=%i&.a=iNextBusFind", date, [self.time hour] > 12 ? [self.time hour]-12 : [self.time hour], [self.time minute], meridiem, self.stop];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [hud setTag:9];
    [hud setAnimationType:MBProgressHUDAnimationZoom];
    [self.view addSubview:hud];
    [hud show:YES];
        
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]]];
    self.activeOp = op;
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.activeOp = nil;
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
        self.errorMessage = nil;
                
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[operation responseData]];
        
        NSArray *elements = [doc searchWithXPathQuery:@"(//div[@class='plainWhiteBoxMedium'])[1]//table//tr[@class='row' or @class='altrow']//td"];
        
        int i = 0;
        NSString *key = nil;
        for (TFHppleElement *element in elements) {
            
            if (i == 7) i = 0;
            
            NSString *content = [[(TFHppleElement *)[[element children] lastObject] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (i == 2) {
                if (![self.buses objectForKey:content]) {
                    [self.buses setObject:[NSMutableArray arrayWithCapacity:3] forKey:content];
                }
                key = [content copy];
                
                [[self.buses objectForKey:key] addObject:[[Bus alloc] init]];
            }
            else if (i == 3) {
                [(Bus *)[[self.buses objectForKey:key] lastObject] setTime:content];
            }
            else if (i == 4) {
                [(Bus *)[[self.buses objectForKey:key] lastObject] setInfo:content];
            }
            
            i++;
        }
        
        [hud hide:YES];
        [hud removeFromSuperview];
        
        [self.tableView reloadData];
    }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                                  self.activeOp = nil;
                                  [timeoutTimer invalidate];
                                  self.timeoutTimer = nil;
                                  
                                  [hud hide:YES];
                                  [hud removeFromSuperview];
                                  
                                  self.errorMessage = [NSString stringWithFormat:@"Error: %@", [error localizedDescription]];
                                  
                                  [self.tableView reloadData];
                              }];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:15
                                             target:self
                                           selector:@selector(didTimeout)
                                           userInfo:nil
                                            repeats:NO];
    [timer fire];
    self.timeoutTimer = timer;
    
    [op start];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.activeOp) {
        [self.activeOp cancel];
    }
    
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didTimeout {
    
    self.errorMessage = @"Operation timed out";
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return MAX([[self.buses allKeys] count], 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([[self.buses allKeys] count] == 0) {
        return 1;
    }
    else {
        return [[self.buses objectForKey:[[self.buses allKeys] objectAtIndex:section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    }
    
    if ([[self.buses allKeys] count] == 0) {
        cell.textLabel.text = [self.view viewWithTag:9] ? @"Loading..." : self.errorMessage ? self.errorMessage : @"No buses";
    }
    else {
        
        Bus *bus = [[[self.buses allValues] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [bus time];
        cell.detailTextLabel.text = [[bus info] isEqualToString:@"No info available"] ? @"No additional information" : [bus info];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([[self.buses allKeys] count] > 0) {
        
        NSString *title = [[self.buses allKeys] objectAtIndex:section];
        if ([title hasPrefix:@"RT "]) {
            return [title substringFromIndex:3];
        }
        else {
            return title;
        }
    }
    
    return @"";
}

@end
