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
#import "IAEEditModeMonthBalanceView.h"
#import "NSNumber+DefaultValues.h"
#import "UIView+LoadFromXib.h"
#import "UIView+RoundedCorners.h"

@interface IAEEditModeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *annualBalanceIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *annualBalanceValueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *monthsScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *monthsScrollPageController;
@property (weak, nonatomic) IBOutlet UIView *conceptsContainerView;

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
    [self configureMonthScrollViewContent];
    [self configureConceptsContainerView];
}

- (void)configureMonthScrollViewContent
{
    self.monthsScrollView.contentSize = CGSizeMake(12 * self.monthsScrollView.bounds.size.width, self.monthsScrollView.bounds.size.height);
    self.monthsScrollView.pagingEnabled = YES;
    self.monthsScrollView.showsHorizontalScrollIndicator = NO;
    self.monthsScrollView.showsVerticalScrollIndicator = NO;
    self.monthsScrollView.bounces = YES;
    self.monthsScrollView.delegate = self;
}

- (void)configureConceptsContainerView
{
    [self.conceptsContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:15];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeAnnualBalanceContent];
    [self vinculeMonthScrollViewContent];
    
    [self goToActualMonth];
}

- (void)goToActualMonth
{
    NSUInteger todayMonthIndex = [[IAEBook sharedBook] findTodayMonthIndex];
    [self.monthsScrollView scrollRectToVisible:[self rectInMonthScrollViewForMonthBalanceViewWithIndex:todayMonthIndex] animated:NO];
}

- (CGRect)rectInMonthScrollViewForMonthBalanceViewWithIndex:(NSUInteger)monthIndex
{
    CGRect rect = CGRectMake(monthIndex * self.monthsScrollView.bounds.size.width,
                             0,
                             self.monthsScrollView.bounds.size.width,
                             self.monthsScrollView.bounds.size.height);
    
    return rect;
}

#pragma mark - Obtainings

- (IAEYear *)actualYear
{
    return [[IAEBook sharedBook] findActualYear];
}

#pragma mark - AnnualBalance (vincule)

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

#pragma mark - ScrollViewMonths (vincule)

- (void)vinculeMonthScrollViewContent
{
    [self createAndAddMonthBalanceItemsToMonthScrollView];
}

- (void)createAndAddMonthBalanceItemsToMonthScrollView
{
    IAEYear *year = [self actualYear];
    for (NSUInteger indexIt = 0; indexIt < year.months.count; ++indexIt) {
        CGRect frame = CGRectMake(self.monthsScrollView.bounds.size.width * indexIt,
                                  0,
                                  self.monthsScrollView.bounds.size.width,
                                  self.monthsScrollView.bounds.size.height);
        IAEEditModeMonthBalanceView *monthBalanceView = [[IAEEditModeMonthBalanceView alloc] initWithFrame:frame andMonthIndex:indexIt];
        
        [self.monthsScrollView addSubview:monthBalanceView];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateScrollPageController];
}

- (void)updateScrollPageController
{
    self.monthsScrollPageController.currentPage = floor((self.monthsScrollView.contentOffset.x / self.monthsScrollView.bounds.size.width) + 0.5);
}


@end
