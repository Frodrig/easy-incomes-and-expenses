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
#import "IAECategoryEditorViewController.h"
#import "IAEYearSelectorViewController.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "NSNumber+DefaultValues.h"
#import "IAECategoryStore.h"
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
@property (nonatomic, weak) IAECategory *categoryRenaming;

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

#pragma mark - ControlEvents

- (IBAction)categoriesButtonPressed:(id)sender
{
    [self openModalForPresentCategorySelectorViewController];
}

- (void)openModalForPresentCategorySelectorViewController
{
    IAECategorySelectorViewController *categorySelectorViewController = [[IAECategorySelectorViewController alloc] initWithAllExtraActionsExceptSelection];
    categorySelectorViewController.delegate = self;
    categorySelectorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:categorySelectorViewController animated:YES completion:nil];
}

- (IBAction)yearsButtonPressed:(id)sender
{
    [self openModalForPresentYearSelectorViewController];
}

- (void)openModalForPresentYearSelectorViewController
{
    IAEYearSelectorViewController *yearSelectorViewController = [[IAEYearSelectorViewController alloc] initWithNibName:nil bundle:nil];
    yearSelectorViewController.delegate = self;
    yearSelectorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:yearSelectorViewController animated:YES completion:nil];
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

- (BOOL)categorySelectorViewControllerWasLaunchedFromCategoryButton
{
    // Nota: Solo tendra sentido si realmente se ha lanzado
    return self.popover == nil;
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
    NSDecimalNumber *yearBalance = [year balance];
    
    [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:self.annualBalanceValueLabel
                                                                        toValue:yearBalance
                                                                   withDuration:animation ? 1.75 : 0 ];
}

- (void)updateMonthBalanceWithAnimation:(BOOL)animation
{
    IAEEditModeMonthBalanceView *monthBalanceView = [self findActualMonthBalanceView];
    
    [monthBalanceView reloadDataWithAnimation:YES];
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
    UIColor *valueColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:yearBalance]];
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

#pragma mark - Varios(Popover)

- (void)dismisPopover
{
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
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
        monthBalanceView.dataSource = self;
        [monthBalanceView reloadDataWithAnimation:NO];
        
        [self.monthsScrollView addSubview:monthBalanceView];
    }
}

#pragma mark - UIPopoverControllerViewDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self updateBalancesIfDismissFromAdjustConceptAmountPopover:popoverController];
}

- (void)updateBalancesIfDismissFromAdjustConceptAmountPopover:(UIPopoverController *)popover
{
    if ([popover.contentViewController isKindOfClass:[IAEAdjustConceptAmountViewController class]]) {
        [self updateBalancesWithAnimation:YES];
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
    if ([self.conceptsCollectionView numberOfItemsInSection:0] > 0) {
        [self.conceptsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - IAEEditModeMonthBalanceViewDataSource

- (NSString *)editModeMonthBalanceView:(IAEEditModeMonthBalanceView *)editModeMonthBalanceView
            monthNameForMonthWithIndex:(NSUInteger)monthIndex
{
    IAEMonth *month = [self findForActualYearMonthAtIndex:monthIndex];
    NSString *monthName = [month description];
    
    return monthName;
}

- (NSDecimalNumber *)editModeMonthBalanceView:(IAEEditModeMonthBalanceView *)editModeMonthBalanceView
                monthBalanceForMonthWithIndex:(NSUInteger)monthIndex
{
    IAEMonth *month = [self findForActualYearMonthAtIndex:monthIndex];
    NSDecimalNumber *monthBalance = [month balance];
    
    return monthBalance;
}

- (IAEMonth *)findForActualYearMonthAtIndex:(NSUInteger)monthIndex
{
    NSAssert(monthIndex >= 0, @"");
    NSAssert(monthIndex < 12, @"");
    IAEYear *year = [self findActualYear];
    IAEMonth *month = [year.ordererMonths objectAtIndex:monthIndex];

    return month;
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
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    UIColor *colorForEconomicValueType = [IAEColorHelper colorForEconomicValueType:economicValueType];
    
    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    [self configureCategoryLabelsOfConceptCell:cell withCategory:category];
    [self configureAmountLabelOfConceptCell:cell withAmountWithSignString:amountWithSignString andColor:colorForEconomicValueType];
}

- (void)configureCategoryLabelsOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                                withCategory:(IAECategory *)category
{
    NSDictionary *categoryNameLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptNameLabelInConceptCell]
                                                                                              andColor:[UIColor blackColor]];
    cell.categoryNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag] attributes:categoryNameLabelAttributes];
    
    NSDictionary *categoryTypeLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptTypeLabelInConceptCell] andColor:[UIColor blackColor]];
    cell.categoryTypeLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedCategoryTypeString] attributes:categoryTypeLabelAttributes];
    
}

- (void)configureAmountLabelOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                 withAmountWithSignString:(NSString *)amountSignedString
                                 andColor:(UIColor *)color
{
    NSDictionary *amountLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForAmountLabelInConceptCell]
                                                                                        andColor:color];
    cell.amountLabel.attributedText = [[NSAttributedString alloc] initWithString:amountSignedString attributes:amountLabelAttributes];
}

- (NSDictionary *)createAttributeDictionaryForConceptCellWithFont:(UIFont *)font andColor:(UIColor *)color
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
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc] initWithExtraActions:CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION];
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
    self.popover.delegate = self;
    self.popover.popoverContentSize = viewController.view.bounds.size;
    [self.popover presentPopoverFromRect:presentPopoverFrame
                                  inView:view.superview
                permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark - IAEAdjustConceptAmountViewControllerDelegate

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

#pragma mark - IAECategorySelectorViewControllerDelegate

- (void)doneButtonWasPressedInCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
{
    NSAssert([self categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
                     didSelectCategory:(IAECategory *)category
{
    NSAssert(![self categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [self dismisPopover];
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
            [self updateBalancesWithAnimation:YES];
        }
    }
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
            didSelectAddCategoryOfType:(CategoryType)categoryType
{
    if ([self categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self launchCategoryEditorViewControllerModalToAddCategoryFromCategorySelectorViewController:categorySelectorViewController
                                                                        andCategoryType:categoryType];
    } else {
        [self dismissPopoverAndLaunchCategoryEditorViewControllerWithCategoryType:categoryType];
    }
}

- (void)launchCategoryEditorViewControllerModalToAddCategoryFromCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController andCategoryType:(CategoryType)categoryType
{
    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToAddCategoryOfType:categoryType];
    categoryEditorViewController.delegate = self;
    categoryEditorViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [categorySelectorViewController presentViewController:categoryEditorViewController animated:YES completion:nil];
}

- (void)dismissPopoverAndLaunchCategoryEditorViewControllerWithCategoryType:(CategoryType)categoryType
{
    [self dismisPopover];
    [self launchCategoryEditorViewControllerAndPrepareInstanceToAddNewCategoryOfType:categoryType];
}

- (void)launchCategoryEditorViewControllerAndPrepareInstanceToAddNewCategoryOfType:(CategoryType)categoryType
{
    self.categoryRenaming = nil;
    
    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToAddCategoryOfType:categoryType];
    categoryEditorViewController.delegate = self;
    
    [self presentViewController:categoryEditorViewController animated:YES completion:nil];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewControler
             didSelectedRenameCategory:(IAECategory *)category
{
    NSAssert([self categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [self launchCategoryEditorViewControllerModalFromCategorySelectorViewController:categorySelectorViewControler ToRenameCategory:category];
}

- (void)launchCategoryEditorViewControllerModalFromCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
                                                                 ToRenameCategory:(IAECategory *)category
{
    self.categoryRenaming = category;
    
    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToRenameCategory:category];
    categoryEditorViewController.delegate = self;
    categoryEditorViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [categorySelectorViewController presentViewController:categoryEditorViewController animated:YES completion:nil];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
               didSelectRemoveCategory:(IAECategory *)category
{
    [[IAECategoryStore sharedCategoryStore] removeCategoryByTag:category.tag];
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView reloadData];
    NSAssert([self categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [categorySelectorViewController reloadData];
}

#pragma mark - IAECategoryEditorViewControllerDelegate

- (void)cancelButtonWasPressedInCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
{
    if ([self categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           DidValidateNewCategoryTag:(NSString *)categoryTag
                      ofCategoryType:(CategoryType)categoryType
{
    IAECategory *newCategory = [[IAECategoryStore sharedCategoryStore] createCategoryOfType:categoryType andTag:categoryTag withValidityTagCheck:NO];
    NSAssert(newCategory, @"");
    if (newCategory) {
        [[IAEBook sharedBook] saveAll];
    }
    
    [self returnFromCategoryEditorViewController:categoryEditorViewController];
}

- (void)returnFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
{
    if ([self categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self returnToUpdatedCategorySelectorViewControllerFromCategoryEditorViewController:categoryEditorViewController];
    } else {
        [self returnToUpdatedEditModeViewControllerFromCategoryEditorViewController:categoryEditorViewController];
    }
}

- (void)returnToUpdatedCategorySelectorViewControllerFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
{
    IAECategorySelectorViewController *categorySelector = (IAECategorySelectorViewController *)categoryEditorViewController.presentingViewController;
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
    [categorySelector reloadData];
    
    [self.conceptsCollectionView reloadData];
}

- (void)returnToUpdatedEditModeViewControllerFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
{
    [self.conceptsCollectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           DidValidateRenameCategory:(IAECategory *)category
                             withTag:(NSString *)tag
{
    category.tag = tag;
    [[IAEBook sharedBook] saveAll];
    
    [self returnFromCategoryEditorViewController:categoryEditorViewController];
}

#pragma mark - IAEYearSelectorViewControllerDelegate

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didLoadSelectedYearDate:(NSUInteger)yearDate
{
    [self reloadAll];
    [self goToActualMonth];
}

- (void)reloadAll
{
    [self reloadAnnualBalance];
    [self reloadMonthsBalance];
    [self reloadMonthConcepts];
}

- (void)reloadAnnualBalance
{
    [self vinculeAnnualBalanceContent];
}

- (void)reloadMonthsBalance
{
    for (UIView *view in self.monthsScrollView.subviews) {
        if ([view isKindOfClass:[IAEEditModeMonthBalanceView class]]) {
            IAEEditModeMonthBalanceView *monthBalance = (IAEEditModeMonthBalanceView *)(view);
            [monthBalance reloadDataWithAnimation:YES];
        }
    }
}

- (void)reloadMonthConcepts
{
    [self.conceptsCollectionView reloadData];
}

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didCreateAndLoadSelectedYearDate:(NSUInteger)yearDate
{
    [self reloadAll];
    [self goToActualMonth];
}

- (void)closeButtonWasPressedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    // ...
}

- (void)actualYearSelectedWasSelectedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    // ...
}


@end
