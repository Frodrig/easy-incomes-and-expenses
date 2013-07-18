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
    
    NSMutableArray *dayOfTheWeekIndexes = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5, @6, @7]];
    if ([IAEVersionHelper isSpanishVersion]) {
        [dayOfTheWeekIndexes exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    
    for (NSNumber *dayIndexIt in dayOfTheWeekIndexes) {
        NSString *labelText = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:[dayIndexIt unsignedIntegerValue] inSortForm:YES];
        NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont fontWithName:dayOfTheWeekFontFamilyName size:dayOfTheWeekFontSize],
                                          NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                          NSKernAttributeName: @0.0};
        
        CGRect dayOfTheWeekFrame = CGRectMake(labelWidth * self.daysOfTheWeekContainerView.subviews.count, 0, labelWidth, labelHeight);
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:dayOfTheWeekFrame];
        dayLabel.backgroundColor = [UIColor clearColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.attributedText = [[NSAttributedString alloc] initWithString:labelText attributes:labelAttributes];
        
        [self.daysOfTheWeekContainerView addSubview:dayLabel];
    }
}


@end
