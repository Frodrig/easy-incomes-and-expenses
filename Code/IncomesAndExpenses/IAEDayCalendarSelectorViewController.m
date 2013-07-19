//
//  IAEDayCalendarSelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDayCalendarSelectorViewController.h"
#import "IAEDayCalendarSelectorViewControllerDelegate.h"
#import "IAECircleDecoratorView.h"
#import "IAEDateHelper.h"
#import "IAEVersionHelper.h"

@interface IAEDayCalendarSelectorViewController ()

@property (nonatomic) NSUInteger yearDate;
@property (nonatomic) NSUInteger monthIndex;
@property (nonatomic) NSUInteger daySelected;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheWeekContainerView;
@property (weak, nonatomic) IBOutlet UIView *daysOfTheMonthContainerView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation IAEDayCalendarSelectorViewController

static NSString * const dayOfTheWeekFontFamilyName = @"HelveticaNeue";
static NSUInteger dayOfTheWeekFontSize = 12;

static NSString * const dayOfTheMonthFontFamilyName = @"HelveticaNeue-Ultralight";
static NSUInteger dayOfTheMonthFontSize = 19;

static NSUInteger tagDaySelectedDecoratorView = 100;

- (instancetype)initWithYearDate:(NSUInteger)yearDate monthIndex:(NSUInteger)monthIndex andDaySelected:(NSUInteger)daySelected
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _yearDate = yearDate;
        _monthIndex = monthIndex;
        _daySelected = daySelected;
        
        [self initTapGestureRecognizer];
    }
    
    return self;
}

- (void)initTapGestureRecognizer
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
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
    [self configureDaySelectedDecoratorView];
    [self configureTapGestureRecognizer];
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
    
    NSArray *dayOfTheWeekIndexes = [IAEVersionHelper isSpanishVersion] ? @[@2, @3, @4, @5, @6, @7, @1] : @[@1, @2, @3, @4, @5, @6, @7];
    for (NSNumber *dayIndexIt in dayOfTheWeekIndexes) {
        NSString *labelText = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:[dayIndexIt unsignedIntegerValue] inShortForm:YES];
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
                dayLabel.tag = dayIt;
                
                [self.daysOfTheMonthContainerView addSubview:dayLabel];
                
                ++dayIt;
            }
        }
    }
}

- (void)configureDaySelectedDecoratorView
{
    UILabel *dayLabel = [self findLabelForActualDaySelected];
    if (dayLabel != nil) {
        CGRect circleFrame = CGRectMake(dayLabel.frame.origin.x,
                                        dayLabel.frame.origin.y,
                                        dayLabel.frame.size.width,
                                        dayLabel.frame.size.height);
        IAECircleDecoratorView *circleDecoratorView = [[IAECircleDecoratorView alloc] initWithFrame:circleFrame];
        circleDecoratorView.circleColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.75];
        circleDecoratorView.backgroundColor = [UIColor clearColor];
        circleDecoratorView.tag = tagDaySelectedDecoratorView;
        
        [self.daysOfTheMonthContainerView insertSubview:circleDecoratorView belowSubview:dayLabel];
    }
}

- (UILabel *)findLabelForActualDaySelected
{
    UILabel *label = self.daySelected != 0 ? (UILabel *)[self.daysOfTheMonthContainerView viewWithTag:self.daySelected] : nil;
    return label;
}

- (void)removeDaySelectedDecoratorView
{
    UIView *decorator = [self.daysOfTheMonthContainerView viewWithTag:tagDaySelectedDecoratorView];
    [decorator removeFromSuperview];
}

- (void)configureTapGestureRecognizer
{
    [self.daysOfTheMonthContainerView addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - TapGestureRecognizer

- (void)tapGestureDetected:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint location = [tapGestureRecognizer locationInView:self.daysOfTheMonthContainerView];
    UILabel *selectedDayLabelAtLocation = [self findSelectedDayLabelAtLocation:location];
    if ([self findLabelForActualDaySelected] != selectedDayLabelAtLocation) {
        [self removeDaySelectedDecoratorView];
        self.daySelected = selectedDayLabelAtLocation.tag;
        [self configureDaySelectedDecoratorView];;
        
        [self.delegate dayCalendarSelectorViewController:self didSelectDay:self.daySelected];
    }
}

- (UILabel *)findSelectedDayLabelAtLocation:(CGPoint)location
{
    CGPoint columnAndRow = [self findColumnAndRowOfLocationInDayOfTheMonthContainer:location];
    NSUInteger day = [self findDayAtColumnAndRow:columnAndRow];
    UILabel *label = (UILabel *)[self.daysOfTheMonthContainerView viewWithTag:day];
    
    return label;
}

- (CGPoint)findColumnAndRowOfLocationInDayOfTheMonthContainer:(CGPoint)location
{
    const NSUInteger numberOfColumns = 7;
    const NSUInteger numberOfRows = 5;
    const NSUInteger dayOfTheMonthWidthSize = self.daysOfTheMonthContainerView.bounds.size.width / numberOfColumns;
    const NSUInteger dayOfTheMonthHeightSize = self.daysOfTheMonthContainerView.bounds.size.height / numberOfRows;
    
    CGPoint columnAndRow = CGPointMake(floorf(location.x / dayOfTheMonthWidthSize), floorf(location.y / dayOfTheMonthHeightSize));
    return columnAndRow;
}

- (NSUInteger)findDayAtColumnAndRow:(CGPoint)columnAndRow
{
    const NSUInteger numberOfColumns = 7;
    const NSUInteger firstDayOfTheWeekIndex = [IAEDateHelper findFirstDayWeekOfTheMonth:self.monthIndex ofYearDate:self.yearDate];
    NSUInteger day = (columnAndRow.y * numberOfColumns + columnAndRow.x + 1) - (firstDayOfTheWeekIndex - 1);
    
    return day;
}

@end
