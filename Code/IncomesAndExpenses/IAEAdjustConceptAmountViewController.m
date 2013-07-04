//
//  IAEAdjustConceptAmountViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAdjustConceptAmountViewController.h"
#import "IAEAdjustConceptAmountViewControllerDelegate.h"
#import "IAECurrencyManager.h"

@interface IAEAdjustConceptAmountViewController ()

@property (weak, nonatomic) IBOutlet UILabel *incrementAmountLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation IAEAdjustConceptAmountViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setIncrementAmountLabelValue];
}

- (void)setIncrementAmountLabelValue
{
    NSNumber *actualSliderValue = [self convertSliderValueToDesiredValue];
    self.incrementAmountLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:actualSliderValue];
}

- (NSNumber *)convertSliderValueToDesiredValue
{
    const float stepperRadius = 1.0 / 3.0;
    float retValue = self.slider.value;
    if (retValue < 1.0 + stepperRadius) {
        retValue = 0.01;
    } else if (retValue > 3.0 - stepperRadius) {
        retValue = 1.0;
    } else {
        retValue = 0.1;
    }
    
    return [NSNumber numberWithFloat:retValue];
}

#pragma mark - Control Events

- (IBAction)incomeButtonPressed:(id)sender
{
    [self.delegate adjustConceptsAmountViewController:self didPressedIncomeButtonWithAmount:[self convertSliderValueToDesiredValue]];
}

- (IBAction)expenseButtonPressed:(id)sender
{
    [self.delegate adjustConceptsAmountViewController:self didPressedExpenseButtonWithAmount:[self convertSliderValueToDesiredValue]];
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self setIncrementAmountLabelValue];
}

@end
