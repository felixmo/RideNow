//
//  RootViewController.m
//  RideNow
//
//  Created by Felix Mo on 2012-07-29.
//  Copyright (c) 2012 Felix Mo. All rights reserved.
//

#import "RootViewController.h"
#import "TapkuLibrary.h"
#import "NSDate-Utilities.h"
#import "DetailViewController.h"

@interface RootViewController ()

@property (strong, nonatomic) TKLabelTextFieldCell *stopFieldCell;
@property (strong, nonatomic) TKLabelTextFieldCell *timeFieldCell;
@property (strong, nonatomic) TKButtonCell *btnCell;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *time;

@end

@implementation RootViewController

@synthesize stopFieldCell;
@synthesize timeFieldCell;
@synthesize btnCell;
@synthesize dateFormatter;
@synthesize time;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Ride Now";
        
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Init. cells
    self.stopFieldCell = [[TKLabelTextFieldCell alloc] init];
    self.stopFieldCell.label.text = @"Stop #";
    self.stopFieldCell.field.delegate = self;
    self.stopFieldCell.field.tag = 1;
    self.stopFieldCell.field.keyboardType = UIKeyboardTypeNumberPad;
    self.stopFieldCell.field.placeholder = @"1869";
    
    self.timeFieldCell = [[TKLabelTextFieldCell alloc] init];
    self.timeFieldCell.label.text = @"Time";
    self.timeFieldCell.field.tag = 2;

    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 220.0f)];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setMinuteInterval:5];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:-60*15]];
    [datePicker setMaximumDate:[[NSDate date] dateByAddingDays:3]];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self.timeFieldCell.field
                                                               action:@selector(resignFirstResponder)];
    [toolbar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    
    self.timeFieldCell.field.inputView = datePicker;
    self.timeFieldCell.field.inputAccessoryView = toolbar;
    
    
    self.btnCell = [[TKButtonCell alloc] init];
    self.btnCell.textLabel.text = @"Go!";
    
    self.time = [NSDate date];
    
    UIBarButtonItem *mapBtn = [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(showMap)];
    self.navigationItem.rightBarButtonItem = mapBtn;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length <= 3 || string.length == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark -

- (void)dateChanged:(id)sender {

    self.time = [sender date];
}

- (void)setTime:(NSDate *)value {
    
    time = value;
    [self.timeFieldCell.field setText:[self.dateFormatter stringFromDate:time]];
}

- (void)showMap {
    
    StopsMapViewController *mapView = [[StopsMapViewController alloc] init];
    mapView.delegate = self;
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:mapView];
    
    [self presentModalViewController:mapNav animated:YES];
}

- (void)didSelectStopWithStopCode:(int)code {
    self.stopFieldCell.field.text = [NSString stringWithFormat:@"%i", code];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == 0 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                case 0:
                    return self.stopFieldCell;
                    break;
                case 1:
                    return self.timeFieldCell;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 1:
            
            switch (indexPath.row) {
                case 0:
                    return self.btnCell;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        if ([self.stopFieldCell.field.text length] < 4) {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please enter a 4-digit stop number."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Continue"
                                                  otherButtonTitles:nil];
            [error show];
        }
        else {
            DetailViewController *detailView = [[DetailViewController alloc] initWithStop:[self.stopFieldCell.field.text intValue]
                                                                                  andTime:self.time];
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
}

@end
