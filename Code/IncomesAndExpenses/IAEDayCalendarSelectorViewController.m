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

static NSString * const kDayOfTheWeekFontFamilyName = @"HelveticaNeue";
static const NSUInteger kDayOfTheWeekFontSize = 12;

static NSString * const kDayOfTheMonthFontFamilyName = @"HelveticaNeue-Ultralight";
static const NSUInteger kDayOfTheMonthFontSize = 17;

static const NSUInteger kTagDaySelectedDecoratorView = 100;
static const CGFloat kRadiousCircleDecoratorScale = 0.85;
static const CGFloat kWhiteColorComponentForCircle = 0.9;
static const CGFloat kWhiteAlphaComponentForCircle = 1.0;

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
    NSString *monthName = [IAEDateHelper findMonthNameStringWithMonthIndex:self.monthIndex inShortForm:NO];

    self.navigationBarTitle.title = [NSString stringWithFormat:NSLocalizedString(@"LTEXT_CALENDARDAYSELECTOR_TITLE", ""), monthName, yearName];
}

- (void)configureDaysOfTheWeekContainerView
{
    const NSUInteger numberOfDays = 7;
    const CGFloat labelWidth = self.daysOfTheWeekContainerView.bounds.size.width / numberOfDays;
    const CGFloat labelHeight = self.daysOfTheWeekContainerView.bounds.size.height;
    
    NSArray *dayOfTheWeekIndexes = @[@2, @3, @4, @5, @6, @7, @1];
    for (NSNumber *dayIndexIt in dayOfTheWeekIndexes) {
        NSString *labelText = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:[dayIndexIt unsignedIntegerValue] inShortForm:YES];
        NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont fontWithName:kDayOfTheWeekFontFamilyName size:kDayOfTheWeekFontSize],
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
    const NSUInteger firstDayOfTheWeek = [self firstDayOfTheWeekNormalized];
    const NSUInteger firstDayOfTheWeekIndex = firstDayOfTheWeek - 1;
    const NSUInteger maxDaysInMonth = [IAEDateHelper findNumberOfDaysFromYearDate:self.yearDate andMonthIndex:self.monthIndex];
    const NSUInteger numberOfColumns = 7;
    const NSUInteger numberOfRows = ceil(((maxDaysInMonth / 7.0) + (firstDayOfTheWeekIndex / 7.0)));
    const NSUInteger dayOfTheMonthWidthSize = self.daysOfTheMonthContainerView.bounds.size.width / numberOfColumns;
    const NSUInteger dayOfTheMonthHeightSize = self.daysOfTheMonthContainerView.bounds.size.height / numberOfRows;
    
    NSUInteger dayIt = 1;
    for (NSUInteger rowIt = 0; rowIt < numberOfRows; rowIt++) {
        for (NSUInteger columnIt = 0; columnIt < numberOfColumns; ++columnIt) {
            const BOOL validDayForMonth = (rowIt > 0 || columnIt >= firstDayOfTheWeekIndex) && (dayIt <= maxDaysInMonth);
            if (validDayForMonth) {
                CGRect labelRect = CGRectMake(columnIt * dayOfTheMonthWidthSize,
                                              rowIt * dayOfTheMonthHeightSize,
                                              dayOfTheMonthWidthSize,
                                              dayOfTheMonthHeightSize);
                NSString *labelText = [NSString stringWithFormat:@"%d", dayIt];
                NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont fontWithName:kDayOfTheMonthFontFamilyName size:kDayOfTheMonthFontSize],
                                                  NSForegroundColorAttributeName: [UIColor darkTextColor]};
                
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

- (NSUInteger)firstDayOfTheWeekNormalized
{
    // El calendario siempre comienza en lunes visualmente
    // Si esetamos en un formato regional que comienza en domingo (el primer dia de la semana es 1, domingo, en lugar de 2, lunes) deberemos de
    // normalizar a lunes.
    NSUInteger firstDayOfTheWeek = [IAEDateHelper findFirstDayWeekFromYearDate:self.yearDate andMonthIndex:self.monthIndex];
    const NSUInteger firstWeekDayOfCurrentRegionalCalendar = [[IAEDateHelper findCurrentCalendar] firstWeekday];
    if (firstWeekDayOfCurrentRegionalCalendar != 2) {
        if (firstDayOfTheWeek == 1) {
            firstDayOfTheWeek = 7;
        } else {
            firstDayOfTheWeek -= 1;
        }
    }

    return firstDayOfTheWeek;
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
        circleDecoratorView.backgroundColor = [UIColor clearColor];
        circleDecoratorView.circleColor = [UIColor colorWithWhite:kWhiteColorComponentForCircle
                                                            alpha:kWhiteAlphaComponentForCircle];
        circleDecoratorView.tag = kTagDaySelectedDecoratorView;
        circleDecoratorView.radiusScale = kRadiousCircleDecoratorScale;
        
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
    UIView *decorator = [self.daysOfTheMonthContainerView viewWithTag:kTagDaySelectedDecoratorView];
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
        [self configureDaySelectedDecoratorView];
        
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
    const NSUInteger firstDayOfTheWeekIndex = [self firstDayOfTheWeekNormalized];
    NSUInteger day = (columnAndRow.y * numberOfColumns + columnAndRow.x + 1) - (firstDayOfTheWeekIndex - 1);
    
    return day;
}

@end
