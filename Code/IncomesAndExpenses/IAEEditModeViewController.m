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
#import "IAEConcept.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEEditModeMonthBalanceView.h"
#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEValueDecoratorView.h"
#import "NSNumber+DefaultValues.h"
#import "UIView+LoadFromXib.h"
#import "UIView+RoundedCorners.h"

@interface IAEEditModeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *annualBalanceIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *annualBalanceValueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *monthsScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *monthsScrollPageController;
@property (weak, nonatomic) IBOutlet UIView *conceptsContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;

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
    [self configureConceptsViews];
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

- (void)configureConceptsViews
{
    [self configureConceptsContainerView];
    [self configureConceptsCollectionView];
}

- (void)configureConceptsContainerView
{
    [self.conceptsContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:15];
}

- (void)configureConceptsCollectionView
{
    [self.conceptsCollectionView registerNib:[UINib nibWithNibName:@"IAEEditModeConceptCollectionViewCell" bundle:[NSBundle mainBundle]]
                  forCellWithReuseIdentifier:@"EditModeConceptCell"];
    
    self.conceptsCollectionView.backgroundColor = [UIColor clearColor];
    self.conceptsCollectionView.showsHorizontalScrollIndicator = NO;
    self.conceptsCollectionView.showsVerticalScrollIndicator = NO;
 
    self.conceptsCollectionView.delegate = self;
    self.conceptsCollectionView.dataSource = self;
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
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
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

- (NSUInteger)findTodayMonthIndex
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit fromDate:today];
    
    return [monthComponents month] - 1;
}

- (IAEYear *)findActualYear
{
    return [[IAEBook sharedBook] findActualYear];
}

- (IAEMonth *)findActualMonth
{
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
    IAEYear *year = [self findActualYear];
    
    return [year.ordererMonths objectAtIndex:todayMonthIndex];
}

- (IAEConcept *)findConceptAtIndexPath:(NSIndexPath *)indexPath
{
    IAEMonth *actualMonth = [self findActualMonth];
    NSArray *concepts = [actualMonth allConceptsSortedByDate];
    IAEConcept *concept = [concepts objectAtIndex:indexPath.row];
    
    return concept;
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
    NSDecimalNumber *yearBalance = [self findActualYear].balance;
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
    IAEYear *year = [self findActualYear];
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

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    IAEMonth *month = [self findActualMonth];
    NSUInteger conceptsOfMonth = month.concepts.count;
    
    return conceptsOfMonth;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(collectionView == self.conceptsCollectionView, @"Se ha recibido una collection view no esperada");
    static NSString *cellId = @"EditModeConceptCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    [self configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:(NSIndexPath *)indexPath
{
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    
    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeOfEconomicValue:[concept amountWithSign]];
}

#pragma mark - UICollectionView Delegate


@end
