//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeViewController.h"
#import "IAECurrencyManager.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"
#import "NSNumber+DefaultValues.h"

@interface IAEEditModeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *annualBalanceIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *annualBalanceValueLabel;

@end

@implementation IAEEditModeViewController

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
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeAnnualBalanceContent];
}

- (IAEYear *)actualYear
{
    return [[IAEBook sharedBook] findActualYear];
}

#pragma mark - AnnualBalance

- (void)vinculeAnnualBalanceContent
{
    [self vinculeAnnualBalanceIndicatorLabel];
    [self vinculeAnnualBalanceValueLabel];
}

- (void)vinculeAnnualBalanceIndicatorLabel
{
    NSString *localizedString = NSLocalizedString(@"TAG_EDITMODE_ANNUALBALANCEINDICATOR", @"");
    UIColor *color = [UIColor colorWithWhite:0.0 alpha:1.0];
    NSDictionary *attributeDictionary = [self createAttributeDictionaryForAnnualBalanceLabelsWithColor:color];

    self.annualBalanceIndicatorLabel.attributedText = [[NSAttributedString alloc] initWithString:localizedString attributes:attributeDictionary];
}

- (void)vinculeAnnualBalanceValueLabel
{
    NSDecimalNumber *yearBalance = [self actualYear].balance;
    UIColor *valueColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeOfEconomicValue:yearBalance]];
    NSDictionary *attributeDictionary = [self createAttributeDictionaryForAnnualBalanceLabelsWithColor:valueColor];
    NSString *stringWithValue = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:yearBalance];
    
    self.annualBalanceValueLabel.attributedText = [[NSAttributedString alloc] initWithString:stringWithValue attributes:attributeDictionary];
}

- (NSDictionary *)createAttributeDictionaryForAnnualBalanceLabelsWithColor:(UIColor *)color
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForAnnualBalanceLabels],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:2.0]};
    
    return attributes;
}

- (UIFont *)createFontForAnnualBalanceLabels
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28];
    
    return font;
}


@end
