//
//  IAEAmountStepperViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 25/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAmountStepperViewController.h"
#import "IAEConstants.h"
#import "IAECurrencyManager.h"
#import "IAEViewUtils.h"

@interface IAEAmountStepperViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundViewForMinusButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundViewForPlusButton;
@property (weak, nonatomic) IBOutlet UILabel *incrementAmountLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation IAEAmountStepperViewController

@synthesize backgroundViewForMinusButton = backgroundViewForMinusButton_;
@synthesize backgroundViewForPlusButton = backgroundViewForPlusButton_;
@synthesize incrementAmountLabel = incrementAmountLabel_;
@synthesize delegate = delegate_;
@synthesize slider = slider_;

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
    self.backgroundViewForMinusButton.backgroundColor = [IAEConstants expenseValueColor];
    self.backgroundViewForPlusButton.backgroundColor = [IAEConstants incomeValueColor];
    [IAEViewUtils addRoundedCorners:UIRectCornerBottomRight withRadius:4.0 toView:self.backgroundViewForMinusButton];
    [IAEViewUtils addRoundedCorners:UIRectCornerBottomLeft withRadius:4.0 toView:self.backgroundViewForPlusButton];
    
    [self scrollValueChanged:self.slider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundViewForMinusButton:nil];
    [self setBackgroundViewForPlusButton:nil];
    [self setIncrementAmountLabel:nil];
    [self setSlider:nil];
    [super viewDidUnload];
}

#pragma mark - ControlEvents

- (float)convertSliderValueToDesiredValue {
    const float stepperRadius = 1.0 / 3.0;
    float retValue = self.slider.value;
    if (retValue < 1.0 + stepperRadius) {
        retValue = 0.01;
    } else if (retValue > 3.0 - stepperRadius) {
        retValue = 1.0;
    } else {
        retValue = 0.1;
    }
    return retValue;
}

- (IBAction)plusButtonPressed:(id)sender {
    [self.delegate onPlusButtonPressed:self withAmount:[NSNumber numberWithFloat:[self convertSliderValueToDesiredValue]]];
}

- (IBAction)minusButtonPressed:(id)sender {
    [self.delegate onMinusButtonPressed:self withAmount:[NSNumber numberWithFloat:-1.0 * [self convertSliderValueToDesiredValue]]];
}

- (IBAction)scrollValueChanged:(UISlider *)sender {
    float actualSliderValue = [self convertSliderValueToDesiredValue];
    self.incrementAmountLabel.text = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[NSNumber numberWithFloat:actualSliderValue]];}

@end
