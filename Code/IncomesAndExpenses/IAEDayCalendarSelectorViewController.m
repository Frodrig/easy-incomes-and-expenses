//
//  IAEDayCalendarSelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDayCalendarSelectorViewController.h"
#import "IAEDateHelper.h"
#import "IAEVersionHelper.h"

@interface IAEDayCalendarSelectorViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheWeekContainerView;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheMonthContainerView;
@property (nonatomic) NSUInteger yearDate;
@property (nonatomic) NSUInteger monthIndex;

@end

@implementation IAEDayCalendarSelectorViewController

static NSString * const dayOfTheWeekFontFamilyName = @"HelveticaNeue";
static NSUInteger dayOfTheWeekFontSize = 12;

static NSString * const dayOfTheMonthFontFamilyName = @"HelveticaNeue-Ultralight";
static NSUInteger dayOfTheMonthFontSize = 21;

- (instancetype)initWithYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _yearDate = yearDate;
        _monthIndex = monthIndex;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"");
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBarTitle];
    [self configureDaysOfTheWeekContainerView];
    [self configureDaysOfTheMonthContainerView];
}

- (void)configureNavigationBarTitle
{
    NSString *yearName = [NSString stringWithFormat:@"%d", self.yearDate];
    NSString *monthName = [IAEDateHelper findMonthNameStringWithMonthIndex:self.monthIndex];

    self.navigationBarTitle.title = [NSString stringWithFormat:NSLocalizedString(@"LTEXT_CALENDARDAYSELECTOR_TITLE", ""), monthName, yearName];
}

- (void)configureDaysOfTheWeekContainerView
{
    const NSUInteger numberOfDays = 7;
    const CGFloat labelWidth = self.daysOfTheWeekContainerView.bounds.size.width / numberOfDays;
    const CGFloat labelHeight = self.daysOfTheWeekContainerView.bounds.size.height;
    
    // Nota: Son los indices a los dias de la semana que usa IAEDateHelper para devolver sus nombres
    // El indice 1 apunta a domingo y el indice 2 a lunes
    NSArray *dayOfTheWeekIndexes = [IAEVersionHelper isSpanishVersion] ? @[@2, @3, @4, @5, @6, @7, @1] : @[@1, @2, @3, @4, @5, @6, @7];
    
    for (NSNumber *dayIndexIt in dayOfTheWeekIndexes) {
        NSString *labelText = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:[dayIndexIt unsignedIntegerValue] inSortForm:YES];
        NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont fontWithName:dayOfTheWeekFontFamilyName size:dayOfTheWeekFontSize],
                                          NSForegroundColorAttributeName: [UIColor darkTextColor],
                                          NSKernAttributeName: @0.0};
        
        CGRect dayOfTheWeekFrame = CGRectMake(labelWidth * self.daysOfTheWeekContainerView.subviews.count, 0, labelWidth, labelHeight);
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:dayOfTheWeekFrame];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.attributedText = [[NSAttributedString alloc] initWithString:labelText attributes:labelAttributes];
        
        [self.daysOfTheWeekContainerView addSubview:dayLabel];
    }
}

- (void)configureDaysOfTheMonthContainerView
{
    const NSUInteger numberOfColumns = 7;
    const NSUInteger numberOfRows = 5;
    const NSUInteger dayOfTheMonthWidthSize = self.daysOfTheMonthContainerView.bounds.size.width / numberOfColumns;
    const NSUInteger dayOfTheMonthHeightSize = self.daysOfTheMonthContainerView.bounds.size.height / numberOfRows;
    const NSUInteger firstDayOfTheWeekIndex = [IAEDateHelper findFirstDayWeekOfTheMonth:self.monthIndex ofYearDate:self.yearDate];
    const NSUInteger maxDaysInMonth = [IAEDateHelper findNumberOfDaysOfMonth:self.monthIndex ofYearDate:self.yearDate];
    
    NSUInteger dayIt = 1;
    for (NSUInteger rowIt = 0; rowIt < numberOfRows; rowIt++) {
        for (NSUInteger columnIt = 0; columnIt < numberOfColumns; ++columnIt) {
            const BOOL validDayForMonth = (rowIt > 0 || columnIt >= firstDayOfTheWeekIndex - 1) && (dayIt <= maxDaysInMonth);
            if (validDayForMonth) {
                CGRect labelRect = CGRectMake(columnIt * dayOfTheMonthWidthSize,
                                              rowIt * dayOfTheMonthHeightSize,
                                              dayOfTheMonthWidthSize,
                                              dayOfTheMonthHeightSize);
                NSString *labelText = [NSString stringWithFormat:@"%d", dayIt];
                NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont fontWithName:dayOfTheMonthFontFamilyName size:dayOfTheMonthFontSize],
                                                  NSForegroundColorAttributeName: [UIColor darkTextColor],
                                                  NSKernAttributeName: @0.0};
                
                UILabel *dayLabel = [[UILabel alloc] initWithFrame:labelRect];
                dayLabel.textAlignment = NSTextAlignmentCenter;
                dayLabel.backgroundColor = [UIColor clearColor];
                dayLabel.attributedText = [[NSAttributedString alloc] initWithString:labelText attributes:labelAttributes];
                
                [self.daysOfTheMonthContainerView addSubview:dayLabel];
                
                ++dayIt;
            }
        }
    }
}


@end
