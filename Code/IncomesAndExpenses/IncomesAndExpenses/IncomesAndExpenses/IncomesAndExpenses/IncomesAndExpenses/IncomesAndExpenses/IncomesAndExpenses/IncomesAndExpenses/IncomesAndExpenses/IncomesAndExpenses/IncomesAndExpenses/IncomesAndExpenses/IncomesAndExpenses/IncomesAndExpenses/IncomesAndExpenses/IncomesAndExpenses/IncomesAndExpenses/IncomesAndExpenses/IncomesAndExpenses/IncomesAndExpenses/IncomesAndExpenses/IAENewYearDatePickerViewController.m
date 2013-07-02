//
//  IAENewYearDatePickerlViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAENewYearDatePickerViewController.h"
#import "IAEBook.h"
#import <QuartzCore/QuartzCore.h>

@interface IAENewYearDatePickerViewController ()
@property (nonatomic, strong, readonly) NSNumber *actualYear;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *parentViewOfCreateYearButton;
@end

@implementation IAENewYearDatePickerViewController

@synthesize actualYear = actualYear_;
@synthesize delegate = delegate_;
@synthesize picker = picker_;
@synthesize doneButton = doneButton_;
@synthesize parentViewOfCreateYearButton = parentViewOfCreateYearButton_;

- (NSNumber *)actualYear
{
    if (actualYear_ == nil)
    {
        NSDate *actualDate = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:actualDate];
        
        actualYear_ = [NSNumber numberWithInt:dateComponents.year];
    }
    
    return actualYear_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setDoneButtonEnabledBasedInYearSelection];
    self.parentViewOfCreateYearButton.layer.cornerRadius = 10.0;
    self.view.layer.cornerRadius = 10.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPicker:nil];
    [self setParentViewOfCreateYearButton:nil];
    [super viewDidUnload];
}

- (void)setDoneButtonEnabledBasedInYearSelectionOfRow:(NSInteger)row
{
    UILabel *selectedLabel = (UILabel *)[self.picker viewForRow:row forComponent:0];
    self.doneButton.enabled = selectedLabel.enabled;
}

- (void)setDoneButtonEnabledBasedInYearSelection
{
    NSInteger selectedRow = [self.picker selectedRowInComponent:0];
    [self setDoneButtonEnabledBasedInYearSelectionOfRow:selectedRow];
}

#pragma mark - UINotifications

- (IBAction)doneButtonPressed:(id)sender
{
    NSUInteger selectedYear = self.actualYear.unsignedIntegerValue - [self.picker selectedRowInComponent:0];
    
    [self.delegate newYearDatePickerSelectionDoneWithYear:selectedYear];
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *yearLabel;
    if (nil == view) {
        yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, pickerView.frame.size.width, 44.0)];
    }
    else
        yearLabel = (UILabel *)view;
    
    yearLabel.text = [NSString stringWithFormat:@"%d", self.actualYear.unsignedIntValue - row];
    yearLabel.textColor = [UIColor blackColor];
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0];
    
    BOOL userInteractionEnabled = ![[IAEBook sharedBook] existYearDate:[NSNumber numberWithUnsignedInt:self.actualYear.unsignedIntValue - row]];
    yearLabel.userInteractionEnabled = userInteractionEnabled;
    yearLabel.enabled = yearLabel.userInteractionEnabled;
    
    return yearLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setDoneButtonEnabledBasedInYearSelectionOfRow:row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.actualYear.unsignedIntValue;
}

@end
