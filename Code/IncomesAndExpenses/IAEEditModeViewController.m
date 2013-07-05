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
#import "IAECategory.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEEconomicValueUpdater.h"
#import "IAEEditModeMonthBalanceView.h"
#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEValueDecoratorView.h"
#import "IAEAdjustConceptAmountViewController.h"
#import "IAECategorySelectorViewController.h"
#import "NSNumber+DefaultValues.h"
#import "UIView+LoadFromXib.h"
#import "UIView+RoundedCorners.h"
#import "NSDecimalNumber+AbsoluteValue.h"

@interface IAEEditModeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *annualBalanceIndicatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *annualBalanceValueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *monthsScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *monthsScrollPageController;
@property (weak, nonatomic) IBOutlet UIView *conceptsContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UITapGestureRecognizer *tapConceptsRecognizer;
@property (nonatomic) BOOL initialPositioning;

@end

@implementation IAEEditModeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initTapConceptsGestureRecognizer];
    }
    
    return self;
}

- (void)initTapConceptsGestureRecognizer
{
    _tapConceptsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnConceptsCollectionView:)];
    _tapConceptsRecognizer.numberOfTapsRequired = 1;
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
    
    [self.conceptsCollectionView addGestureRecognizer:self.tapConceptsRecognizer];
 
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
    self.initialPositioning = YES;
    
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
    [self.monthsScrollView scrollRectToVisible:[self rectInMonthScrollViewForMonthBalanceViewWithIndex:todayMonthIndex] animated:NO];
    
    self.initialPositioning = NO;
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

- (IAEEditModeMonthBalanceView *)findActualMonthBalanceView
{
    UIView *balanceView = [self.monthsScrollView.subviews objectAtIndex:self.monthsScrollPageController.currentPage];
    
    return (IAEEditModeMonthBalanceView *)balanceView;
}

#pragma mark - Update 

- (void)updateBalancesWithAnimation:(BOOL)animation
{
    [self updateYearBalanceWithAnimation:animation];
    [self updateMonthBalanceWithAnimation:animation];
}

- (void)updateYearBalanceWithAnimation:(BOOL)animation
{
    IAEYear *year = [self findActualYear];
    [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:self.annualBalanceValueLabel
                                                                        toValue:[year balance]
                                                                   withDuration:animation ? 25.0 : 0 ];
}

- (void)updateMonthBalanceWithAnimation:(BOOL)animation
{
    IAEMonth *month = [self findActualMonth];
    IAEEditModeMonthBalanceView *monthBalanceView = [self findActualMonthBalanceView];
    [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:monthBalanceView.monthBalanceLabel
                                                                        toValue:[month balance]
                                                                   withDuration:animation ? 25.0 : 0 ];    
}


- (void)processEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration { }


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
    if (scrollView == self.monthsScrollView) {
        [self updateMonthScrollViewAfterScroll];
    }
}

- (void)updateMonthScrollViewAfterScroll
{
    [self updateScrollPageController];
    if (!self.initialPositioning) {
        [self setConceptsCollectionViewInTransitionAspect:YES];
    }
}

- (void)updateScrollPageController
{
    self.monthsScrollPageController.currentPage = floor((self.monthsScrollView.contentOffset.x / self.monthsScrollView.bounds.size.width) + 0.5);
}

- (void)setConceptsCollectionViewInTransitionAspect:(BOOL)transition
{
    [UIView animateWithDuration:0.25 animations:^{
        self.conceptsCollectionView.alpha = transition ? 0.15 : 1.0;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.monthsScrollView) {
        [self updateContentOfConceptsCollectionView];
        [self setConceptsCollectionViewInTransitionAspect:NO];
    }
}

- (void)updateContentOfConceptsCollectionView
{
    [self.conceptsCollectionView reloadData];
    [self.conceptsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
    // Nota: Por defecto los conceptos tienen el valor absoluto de la cantidad que almacenan de ahi el pedir la cantidad con signo si procede
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    IAECategory *category = concept.category;
    NSDecimalNumber *amountWithSign = [concept amountWithSign];
    NSString *amountWithSignString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:amountWithSign];
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeOfEconomicValue:amountWithSign];
    UIColor *colorForEconomicValueType = [IAEColorHelper colorForEconomicValueType:economicValueType];
    
    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeOfEconomicValue:amountWithSign];
    [self configureCategoryLabelsOfConceptCell:cell withCategory:category];
    [self configureAmountLabelOfConceptCell:cell withAmountWithSignString:amountWithSignString andColor:colorForEconomicValueType];
}

- (void)configureCategoryLabelsOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                                withCategory:(IAECategory *)category
{
    NSDictionary *categoryNameLabelAttributes = [self createdAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptNameLabelInConceptCell]
                                                                                              andColor:[UIColor blackColor]];
    cell.categoryNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag] attributes:categoryNameLabelAttributes];
    
    NSDictionary *categoryTypeLabelAttributes = [self createdAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptTypeLabelInConceptCell] andColor:[UIColor blackColor]];
    cell.categoryTypeLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedCategoryTypeString] attributes:categoryTypeLabelAttributes];
    
}

- (void)configureAmountLabelOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                 withAmountWithSignString:(NSString *)amountSignedString
                                 andColor:(UIColor *)color
{
    NSDictionary *amountLabelAttributes = [self createdAttributeDictionaryForConceptCellWithFont:[self createFontForAmountLabelInConceptCell]
                                                                                        andColor:color];
    cell.amountLabel.attributedText = [[NSAttributedString alloc] initWithString:amountSignedString attributes:amountLabelAttributes];
}

- (NSDictionary *)createdAttributeDictionaryForConceptCellWithFont:(UIFont *)font andColor:(UIColor *)color
{
    NSDictionary *attributes =  @{NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForAmountLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:52];
    return font;
}

- (UIFont *)createFontForCategoryConceptNameLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
    return font;
}

- (UIFont *)createFontForCategoryConceptTypeLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17];
    return font;
}

#pragma mark - UICollectionView Delegate

#pragma mark - UITapGestureRecognizer

- (void)tapOnConceptsCollectionView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:tapGestureRecognizer];
}

- (void)findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint location = [tapGestureRecognizer locationInView:self.conceptsCollectionView];;
    NSIndexPath *locationIndexPath = [self.conceptsCollectionView indexPathForItemAtPoint:location];
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:locationIndexPath];
    CGPoint locationConvertedToCellArea = [cell convertPoint:location fromView:self.conceptsCollectionView];

    [self executeActionOnCellOfConceptCollectionView:cell underTapLocaton:locationConvertedToCellArea];
}

- (void)executeActionOnCellOfConceptCollectionView:(IAEEditModeConceptCollectionViewCell *)cell underTapLocaton:(CGPoint)location
{
    if (CGRectContainsPoint(cell.amountLabel.frame, location)) {
        [self openPopoverForAdjustConceptCellAmount:cell];
    } else if (CGRectContainsPoint(cell.categoryNameLabel.frame, location) ||
               CGRectContainsPoint(cell.categoryTypeLabel.frame, location)) {
        [self openPopoverForEditConceptCellCategory:cell];
    }
}

- (void)openPopoverForAdjustConceptCellAmount:(IAEEditModeConceptCollectionViewCell *)cell
{    
    IAEAdjustConceptAmountViewController *viewController = [[IAEAdjustConceptAmountViewController alloc] init];
    viewController.delegate = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];

    [self createAndPresentPopoverForConceptCellView:cell.amountLabel withViewController:viewController];
}

- (void)openPopoverForEditConceptCellCategory:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc] init];
    viewController.delegate = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];
    
    [self createAndPresentPopoverForConceptCellView:cell.categoryNameLabel withViewController:viewController];
}

- (void)createAndPresentPopoverForConceptCellView:(UIView *)view withViewController:(UIViewController *)viewController
{
    CGRect traslateViewFrameToGlobalCoordination = [view.superview convertRect:view.frame toView:view.superview];
    CGRect presentPopoverFrame = CGRectMake(traslateViewFrameToGlobalCoordination.origin.x,
                                            traslateViewFrameToGlobalCoordination.origin.y + 10.0,
                                            traslateViewFrameToGlobalCoordination.size.width,
                                            traslateViewFrameToGlobalCoordination.size.height - 10.0);
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.popoverContentSize = viewController.view.bounds.size;
    [self.popover presentPopoverFromRect:presentPopoverFrame
                                  inView:view.superview
                permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark - IAEAdjustConceptAmountViewController

- (void)adjustConceptsAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptsAmountViewController
          didPressedAdjustButtonWithAmount:(NSNumber *)amount
{
    [self modifyAmmountOfConceptOfCellIndexPath:adjustConceptsAmountViewController.conceptCellIndexPath byAddingAmmount:amount];
}

- (void)modifyAmmountOfConceptOfCellIndexPath:(NSIndexPath *)cellIndexPath byAddingAmmount:(NSNumber *)amount
{
    IAEMonth *month = [self findActualMonth];
    IAEConcept *concept = [[month allConceptsSortedByDate] objectAtIndex:cellIndexPath.row];
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:cellIndexPath];
    
    if ([self updateWithNewAbsoluteValueOfConcept:concept byAdding:amount]) {
        [self configureEditModeConceptCell:cell withConceptAtIndexPath:cellIndexPath];
        [[IAEBook sharedBook] saveAll];
    }    
}

- (BOOL)updateWithNewAbsoluteValueOfConcept:(IAEConcept *)concept byAdding:(NSNumber *)amount
{
    NSDecimalNumber *amountDecimalNumber = [NSDecimalNumber decimalNumberWithString:[amount stringValue]];
    NSDecimalNumber *conceptAmountWithSign = [concept amountWithSign];
    NSDecimalNumber *newConceptValue = [conceptAmountWithSign decimalNumberByAdding:amountDecimalNumber];
   
    BOOL canUpdate = [concept canAssignSignedValue:newConceptValue];
    if (canUpdate) {
        concept.amount = [newConceptValue decimalNumberByAbsoluteValue];
    }
    
    return canUpdate;
}

#pragma IAECategorySelectorViewControllerDelegate

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController didSelectCategory:(IAECategory *)category
{
    [self.popover dismissPopoverAnimated:YES];
    
    [self changeCategoryOfConceptAtIndexPath:categorySelectorViewController.conceptCellIndexPath toCategory:category];
}

- (void)changeCategoryOfConceptAtIndexPath:(NSIndexPath *)indexPath toCategory:(IAECategory *)category
{
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    if (concept.category != category) {
        CategoryType originalCategoryType = concept.category.categoryType;
        concept.category = category;

        [[IAEBook sharedBook] saveAll];

        IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:indexPath];
        [self configureEditModeConceptCell:cell withConceptAtIndexPath:indexPath];

        if (originalCategoryType != concept.category.categoryType) {
            [self updateBalancesWithAnimation:NO];
        }
    }
}


@end
