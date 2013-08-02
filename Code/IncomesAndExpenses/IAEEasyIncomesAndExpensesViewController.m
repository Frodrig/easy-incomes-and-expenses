//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEasyIncomesAndExpensesViewController.h"
#import "IAECurrencyManager.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEEconomicValueUpdater.h"
#import "IAEContextView.h"
#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEEditModeConceptCollectionViewHeader.h"
#import "IAEValueDecoratorView.h"
#import "IAEAdjustConceptAmountViewController.h"
#import "IAECategorySelectorViewController.h"
#import "IAECategoryEditorViewController.h"
#import "IAEYearSelectorViewController.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEAboutAndOptionsViewController.h"
#import "IAEDayCalendarSelectorViewController.h"
#import "IAECalculatorViewController.h"
#import "IAETextRawSelectorMenuView.h"
#import "IAEReportAreaView.h"
#import "IAEHelperReportAreaViewDataSource.h"
#import "IAEHelperContextTextRawMenuDataSource.h"
#import "IAEHelperReportTextRawMenuDataSource.h"
#import "IAEHelperCalculatorDataSource.h"
#import "IAEHelperConceptsCollectionViewDataSource.h"
#import "NSNumber+DefaultValues.h"
#import "IAECategoryStore.h"
#import "IAEDateHelper.h"
#import "IAENumberUtils.h"
#import "UIView+LoadFromXib.h"
#import "UIView+RoundedCorners.h"
#import "NSDecimalNumber+AbsoluteValue.h"

#import "IAEStrokeAnimatableLineView.h"

@interface IAEEasyIncomesAndExpensesViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *contextScrollView;
@property (weak, nonatomic) IBOutlet UIView *editAndReportModeContentContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;
@property (nonatomic, strong) IAEReportAreaView *reportAreaView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *contextMenuView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *reportMenuView;
@property (nonatomic, strong) IAECalculatorViewController *calculatorViewController;
@property (nonatomic, strong) IAEHelperReportAreaViewDataSource *helperReportAreaViewDataSource;
@property (nonatomic, strong) IAEHelperContextTextRawMenuDataSource *helperContextTextRawMenuDataSource;
@property (nonatomic, strong) IAEHelperReportTextRawMenuDataSource *helperReportTextRawMenuDataSource;
@property (nonatomic, strong) IAEHelperCalculatorDataSource *helperCalculatorDataSource;
@property (nonatomic, strong) IAEHelperConceptsCollectionViewDataSource *helperConceptsCollectionViewDataSource;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UITapGestureRecognizer *tapConceptsRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeConceptsGestureRecognizer;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@property (nonatomic, weak) IAEEditModeConceptCollectionViewCell *conceptCellToRemove;
@property (nonatomic) BOOL initialPositioning;
@property (nonatomic, weak) IAECategory *categoryRenaming;
@property (nonatomic, weak) IAEConcept *conceptChangingDay;
@property (nonatomic) BOOL reloadAllPendingFromYearSelectorIfReturnWithSameYearDate;

@end

@implementation IAEEasyIncomesAndExpensesViewController

#pragma mark - Constants

static const NSUInteger kNumberOfMonths = 12;

static const CGFloat kEditAndReportModeContentContainerRadius = 15;
static const CGFloat kColorWithWhiteForEditAndReportModeContentContainerBackground = 0.97;

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

static NSString * const kLtextModeSegmentedControlEditMode = @"LTEXT_MODESEGMENTEDCONTROL_EDITMODE";
static NSString * const kLtextModeSegmentedControlReportmode = @"LTEXT_MODESEGMENTEDCONTROL_REPORTMODE";

static const NSUInteger kContentScrollViewNumberOfItems = 13;
static const NSUInteger kGlobalIndexForYearInContextScrollView = 0;

static NSString * const kNibConceptCellName = @"IAEEditModeConceptCollectionViewCell";
static NSString * const kIdConceptCellName = @"EditModeConceptCell";

static NSString * const kNibConceptCellHeaderInYearModeName = @"IAEEditModeConceptCollectionViewHeader";
static NSString * const kCollectionViewHeaderIdentifier = @"EditModeConceptHeader";

static const NSUInteger kSegmentedControlIndexEditMode = 0;
static const NSUInteger kSegmentedControlIndexReportMode = 1;

static const NSUInteger kReportMenuIndexOfBalancesOption = 0;
static const NSUInteger kReportMenuIndexOfIncomesOption = 1;
static const NSUInteger kReportMenuIndexOfExpensesOption = 2;

static const CGFloat kDurationStrokeAnimationForConcepts = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimationForConcepts = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimationForConcepts = 1.0;
static const CGFloat kTypeStrokeAnimationForConcepts = STROKEANIMATABLE_TYPE_THIN;
static const CGFloat kDelayToExecuteRemoveConceptCell = 0.2;

static const CGFloat KDurationOfAnimationUpdateForEntryInstantIndex = 0.15;

#pragma mark - Properties

- (IAEStrokeAnimatableLineView *)strokeAnimatableLineView
{
    if (!_strokeAnimatableLineView) {
        _strokeAnimatableLineView = [IAEStrokeAnimatableLineView strokeAnimatableLineView];
        _strokeAnimatableLineView.durationOfStrokeAnimation = kDurationStrokeAnimationForConcepts;
        _strokeAnimatableLineView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimationForConcepts
                                                                  alpha:kColorWhiteAlphaComponentForStrokeAnimationForConcepts];
        _strokeAnimatableLineView.strokeType = kTypeStrokeAnimationForConcepts;
        _strokeAnimatableLineView.delegate = self;
    }
    
    return _strokeAnimatableLineView;
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.conceptsCollectionView removeGestureRecognizer:self.tapConceptsRecognizer];
    [self.conceptsCollectionView removeGestureRecognizer:self.swipeConceptsGestureRecognizer];
}

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommonProperties];
        [self initTapConceptsGestureRecognizer];
        [self initSwipeConceptsGestureRecognizer];
        [self initAsObserverOfNotificationCenter];
        [self initContextMenuView];
        [self initCalculatorViewController];
        [self initReportAreaView];
        [self initReportMenuView];
        [self initHelpers];
    }
    
    return self;
}

- (void)initCommonProperties
{
    self.initialPositioning = YES;
}

- (void)initTapConceptsGestureRecognizer
{
    _tapConceptsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnConceptsCollectionView:)];
    _tapConceptsRecognizer.numberOfTapsRequired = 1;
}

- (void)initSwipeConceptsGestureRecognizer
{
    _swipeConceptsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeOnConceptsCollectionView:)];
    _swipeConceptsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)initAsObserverOfNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOn:)
                                                 name:kNotificationDayModeOnName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOff:)
                                                 name:kNotificationDayModeOffName
                                               object:nil];
}

- (void)initContextMenuView
{
    _contextMenuView = [[IAETextRawSelectorMenuView alloc] init];
    _contextMenuView.backgroundColor = [UIColor clearColor];
}

- (void)initCalculatorViewController
{
    _calculatorViewController = [[IAECalculatorViewController alloc] init];
}

- (void)initReportAreaView
{
    _reportAreaView = [[IAEReportAreaView alloc] init];
}

- (void)initReportMenuView
{
    _reportMenuView = [[IAETextRawSelectorMenuView alloc] init];
}

- (void)initHelpers
{
    _helperReportAreaViewDataSource = [[IAEHelperReportAreaViewDataSource alloc] initWithEasyIncomesViewControllerQuery:self];
    _helperContextTextRawMenuDataSource = [[IAEHelperContextTextRawMenuDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self];
    _helperReportTextRawMenuDataSource = [[IAEHelperReportTextRawMenuDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self];
    _helperCalculatorDataSource = [[IAEHelperCalculatorDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self];
    _helperConceptsCollectionViewDataSource = [[IAEHelperConceptsCollectionViewDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self configureEditAndReportModeContentContainerView];
    [self configureContextScrollViewContent];
    [self configureCalculatorViewController];
    [self configureConceptsViews];
    [self configureReportAreaView];
    [self configureReportMenuView];
}

- (void)configureContextScrollViewContent
{
    self.contextScrollView.contentSize = CGSizeMake(kContentScrollViewNumberOfItems * self.contextScrollView.bounds.size.width,
                                                    self.contextScrollView.bounds.size.height);
    self.contextScrollView.pagingEnabled = YES;
    self.contextScrollView.showsHorizontalScrollIndicator = NO;
    self.contextScrollView.showsVerticalScrollIndicator = NO;
    self.contextScrollView.bounces = YES;
}

- (void)configureCalculatorViewController
{
    _calculatorViewController.delegate = self;
    _calculatorViewController.dataSource = self.helperCalculatorDataSource;
}

- (void)configureConceptsViews
{
    [self configureEditAndReportModeContentContainerView];
    [self configureConceptsCollectionView];
}

- (void)configureEditAndReportModeContentContainerView
{
    [self.editAndReportModeContentContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:kEditAndReportModeContentContainerRadius];
    self.editAndReportModeContentContainerView.backgroundColor = [UIColor colorWithWhite:kColorWithWhiteForEditAndReportModeContentContainerBackground
                                                                                   alpha:1.0];
}

- (void)configureConceptsCollectionView
{
    UINib *nibForConceptCell = [UINib nibWithNibName:kNibConceptCellName bundle:[NSBundle mainBundle]];
    [self.conceptsCollectionView registerNib:nibForConceptCell forCellWithReuseIdentifier:kIdConceptCellName];
    
    UINib *nibForConceptHeaderInYearMode = [UINib nibWithNibName:kNibConceptCellHeaderInYearModeName bundle:[NSBundle mainBundle]];
    [self.conceptsCollectionView registerNib:nibForConceptHeaderInYearMode
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:kCollectionViewHeaderIdentifier];
    
    self.conceptsCollectionView.backgroundColor = [UIColor clearColor];
    self.conceptsCollectionView.showsHorizontalScrollIndicator = NO;
    self.conceptsCollectionView.showsVerticalScrollIndicator = NO;
    
    [self.conceptsCollectionView addGestureRecognizer:self.tapConceptsRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.swipeConceptsGestureRecognizer];
}

- (void)configureReportAreaView
{
    self.reportAreaView.backgroundColor = [UIColor clearColor];
}

- (void)configureReportMenuView
{
    self.reportMenuView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeContextScrollViewContent];
    [self vinculeContextMenuView];
    [self vinculeCalculatorViewControllerView];
    [self vinculeReportAreaView];
    [self vinculeReportMenuView];
    
    [self gotoToTodayMonthWithoutTransitionEffect];

    // Nota: En el momento en que se asigna un datasource al collection view se procede a la carga de informacion.
    //       Antes de que ocurra eso, nos aseguramos de estar en el contexto adecuado.
    [self vinculeConceptsCollectionView];
}

- (void)vinculeConceptsCollectionView
{
    self.conceptsCollectionView.delegate = self;
    self.conceptsCollectionView.dataSource = self.helperConceptsCollectionViewDataSource;
}

- (void)vinculeContextMenuView
{
    [self.view addSubview:_contextMenuView];
    self.contextMenuView.delegate = self;
    self.contextMenuView.dataSource = self.helperContextTextRawMenuDataSource;
    self.contextMenuView.center = CGPointMake(self.view.center.x,
                                              self.contextScrollView.center.y + self.contextScrollView.bounds.size.height / 2 + self.contextMenuView.bounds.size.height / 2);
}

- (void)vinculeReportAreaView
{
    self.reportAreaView.frame = CGRectMake(self.editAndReportModeContentContainerView.frame.origin.x,
                                           self.editAndReportModeContentContainerView.frame.origin.y,
                                           self.editAndReportModeContentContainerView.frame.size.width,
                                           self.editAndReportModeContentContainerView.frame.size.height);
    [self.view addSubview:self.reportAreaView];
    self.reportAreaView.hidden = YES;
}

- (void)vinculeReportMenuView
{
    [self.view addSubview:self.reportMenuView];
    self.reportMenuView.dataSource = self.helperReportTextRawMenuDataSource;
    self.reportMenuView.delegate = self;
    self.reportMenuView.center = CGPointMake(self.view.center.x,
                                             self.reportAreaView.center.y + self.reportAreaView.bounds.size.height / 2 + self.reportMenuView.bounds.size.height / 1.35);
    self.reportMenuView.hidden = YES;
}

- (void)gotoToTodayMonthWithoutTransitionEffect
{
    self.initialPositioning = YES;
    [self goToTodayMonth];
    self.initialPositioning = NO;
}

- (void)goToTodayMonth
{
    NSUInteger globalContextViewIndex = [self findTodayMonthContextViewGlobalIndexInContextScrollView];
    [self gotoToContextViewWithIndex:globalContextViewIndex];
}

- (void)gotoToContextViewWithIndex:(NSUInteger)contextIndex
{
    if (!self.initialPositioning) {
        [self setConceptsCollectionViewInTransitionAspect:YES];
    }
    
    CGRect contextViewRect = [self rectInContextScrollViewForContextViewWithGlobalIndex:contextIndex];
    [self.contextScrollView scrollRectToVisible:contextViewRect animated:NO];
}

- (CGRect)rectInContextScrollViewForContextViewWithGlobalIndex:(NSUInteger)globalIndex
{
    CGRect rect = CGRectMake(globalIndex * self.contextScrollView.bounds.size.width,
                             0,
                             self.contextScrollView.bounds.size.width,
                             self.contextScrollView.bounds.size.height);
    
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

- (IBAction)settingsOptionPressed:(id)sender
{
    IAEAboutAndOptionsViewController *aboutAndOptionsViewController = [[IAEAboutAndOptionsViewController alloc] initWithNibName:nil bundle:nil];
    aboutAndOptionsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:aboutAndOptionsViewController animated:YES completion:nil];
}

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender
{
    if ([self isEditModeActive]) {
        [self updateAfterChangeToEditMode];
    } else if ([self isReportModeActive]) {
        [self updateAfterChangeToReportMode];
    }
}

- (BOOL)isEditModeActive
{
    BOOL isEditMode = self.modeSegmentedControl.selectedSegmentIndex == kSegmentedControlIndexEditMode;
    
    return isEditMode;
}

- (BOOL)isReportModeActive
{
    BOOL isReportMode = self.modeSegmentedControl.selectedSegmentIndex == kSegmentedControlIndexReportMode;
    
    return isReportMode;
}

- (void)updateAfterChangeToEditMode
{
    [self.conceptsCollectionView reloadData];
    [self updateCalculatorViewHideHalfState];
    
    self.editAndReportModeContentContainerView.backgroundColor = [UIColor colorWithWhite:kColorWithWhiteForEditAndReportModeContentContainerBackground
                                                                                   alpha:1.0];
    self.conceptsCollectionView.hidden = NO;
    self.calculatorViewController.view.hidden = NO;
    self.reportAreaView.hidden = YES;
    self.reportMenuView.hidden = YES;
    self.reportAreaView.dataSource = nil;
    self.reportAreaView.delegate = nil;
}

- (void)updateAfterChangeToReportMode
{
    self.editAndReportModeContentContainerView.backgroundColor = [UIColor clearColor];

    self.conceptsCollectionView.hidden = YES;
    self.calculatorViewController.view.hidden = YES;
    self.reportAreaView.hidden = NO;
    self.reportMenuView.hidden = NO;
    self.reportMenuView.currentOptionIndexSelected = kReportMenuIndexOfBalancesOption;
    self.reportAreaView.dataSource = self.helperReportAreaViewDataSource;
    self.reportAreaView.delegate = self;
}

#pragma mark - IAEEasyIncomesAndExpensesViewControllerQuery

- (IAEYear *)findOpenYear
{
    return [[IAEBook sharedBook] findActualYear];
}

- (IAEMonth *)findActualSelectedMonth
{
    IAEMonth *month = nil;
    if (self.contextMenuView.currentOptionIndexSelected != kGlobalIndexForYearInContextScrollView) {
        NSUInteger actualMonthIndex = self.contextMenuView.currentOptionIndexSelected - 1;
        month = [self findMonthForOpenYearAtIndex:actualMonthIndex];
    }
    
    return month;
}

- (BOOL)isTheBalancesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfBalancesOption];
    
    return isSelected;
}

- (BOOL)isTheIncomesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfIncomesOption];
    
    return isSelected;
}

- (BOOL)isTheExpensesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfExpensesOption];
    
    return isSelected;
}

- (BOOL)isReportMenuViewSelectedWithTheOptionIndex:(NSUInteger)optionIndex
{
    BOOL isSelected = optionIndex == [self findCurrentOptionIndexSelectedInReportMenuView];
    
    return isSelected;
}

- (NSUInteger)findCurrentOptionIndexSelectedInReportMenuView
{
    return self.reportMenuView.currentOptionIndexSelected;
}

- (NSDecimalNumber *)findMaxValueOfAllCategoriesForActualSelectedContext
{
    NSDecimalNumber *maxValue = [NSDecimalNumber zero];
    
    id modelObject = [self findModelObjectOfActualSelectedContextView];
    NSSet *allCategories = [self findAllCategoriesForActualSelectedContext];
    for (IAECategory *category in allCategories) {
        NSDecimalNumber *categoryValue = [modelObject balanceOfAllConceptsOfCategory:category];
        if ([categoryValue compare:maxValue] == NSOrderedDescending) {
            maxValue = categoryValue;
        }
    }
    
    return maxValue;
}

- (NSSet *)findAllCategoriesForActualSelectedContext
{
    NSArray *incomeCategories = [self findIncomesCategoriesOfActualSelectedContextView];
    NSArray *expenseCategories = [self findExpensesCategoriesOfActualSelectedContextView];
    NSSet *allCategories = [NSSet setWithArray:incomeCategories];
    allCategories = [allCategories setByAddingObjectsFromArray:expenseCategories];
    
    return allCategories;
}

- (NSDecimalNumber *)findIncomesOfActualSelectedContextView
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSDecimalNumber *incomes = [modelObj incomes];
    
    return incomes;
}

- (NSDecimalNumber *)findExpensesOfActualSelectedContextView
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSDecimalNumber *expenses = [modelObj expenses];
    
    return expenses;
}

- (NSArray *)findIncomesCategoriesOfActualSelectedContextView
{
    NSArray *categories = [self findCategoriesOfActualSelectedContextViewWithType:IncomeCategory];
    
    return categories;
}

- (NSArray *)findExpensesCategoriesOfActualSelectedContextView
{
    NSArray *categories = [self findCategoriesOfActualSelectedContextViewWithType:ExpenseCategory];
    
    return categories;
}

- (id)findModelObjectOfActualSelectedContextView
{
    id modelObject;
    
    if ([self isActualSelectedContextTheYearOpen]) {
        modelObject = [self findOpenYear];
    } else if ([self isActualSelectedContextAMonth]) {
        modelObject = [self findActualSelectedMonth];
    }
    
    return modelObject;
}

- (BOOL)isActualSelectedContextTheYearOpen
{
    return self.contextMenuView.currentOptionIndexSelected == kGlobalIndexForYearInContextScrollView ? YES : NO;
}

- (BOOL)isActualSelectedContextAMonth
{
    return [self isActualSelectedContextTheYearOpen] ? NO : YES;
}

- (CGSize)findMainViewSize
{
    return self.view.bounds.size;
}

- (NSArray *)findAllOrdererMonthsWithConceptsOfOpenYear
{
    IAEYear *openYear = [self findOpenYear];
    NSArray *months = [openYear findAllOrdererMonthsWithConcepts];
    
    return months;
}

- (UICollectionView *)findConceptsCollectionView
{
    return self.conceptsCollectionView;
}

- (IAEConcept *)findConceptAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *concepts = [self allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:indexPath];
    IAEConcept *concept = [concepts objectAtIndex:indexPath.row];
    
    return concept;
}

- (NSUInteger)findNumberOfConceptsOfActualSelectedContext:(NSInteger)section
{
    NSUInteger numberOfConcepts = 0;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *month = [self findActualSelectedMonth];
        numberOfConcepts = month.concepts.count;
    } else {
        NSArray *months = [self findAllOrdererMonthsWithConceptsOfOpenYear];
        IAEMonth *month = months[section];
        numberOfConcepts = month.concepts.count;
    }
    
    return numberOfConcepts;
}

- (BOOL)isDayModeActiveForConcepts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

- (NSString *)findDayOfTheWeekNameFromConcept:(IAEConcept *)concept
{
    NSUInteger dayOfTheWeekIndex = [IAEDateHelper findDayOfTheWeekIndexFromYearDate:concept.month.year.yearDate
                                                                         monthIndex:concept.month.month
                                                                   andDayOfTheMonth:concept.dayOfTheMonth];
    NSString *dayOfTheWeekName = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:dayOfTheWeekIndex inShortForm:NO];
    
    return dayOfTheWeekName;
}

#pragma mark - Finds

- (NSUInteger)findTodayMonthContextViewGlobalIndexInContextScrollView
{
    NSUInteger todayMonthContextViewGlobalIndex = [self findTodayMonthIndex] + 1;
  
    return todayMonthContextViewGlobalIndex;
}

- (NSUInteger)findTodayMonthIndex
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit fromDate:today];
    
    return [monthComponents month] - 1;
}

- (IAEMonth *)findMonthOfPresentDay
{
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
    return [self findMonthForOpenYearAtIndex:todayMonthIndex];
}

- (IAEMonth *)findMonthForOpenYearAtIndex:(NSUInteger)index
{
    IAEYear *year = [self findOpenYear];
    return [year.ordererMonths objectAtIndex:index];
}

- (NSArray *)allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *allConcepts = nil;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *actualMonth = [self findActualSelectedMonth];
        allConcepts = [self isDayModeActiveForConcepts] ? [actualMonth  allConceptsSortedByDay] : [actualMonth allConceptsSortedByEntryInstant];
    } else {
        NSArray *months = [self findAllOrdererMonthsWithConceptsOfOpenYear];
        IAEMonth *month = months[indexPath.section];
        allConcepts = [self isDayModeActiveForConcepts] ? [month allConceptsSortedByDay] : [month allConceptsSortedByEntryInstant];
    }
    
    return allConcepts;
}

- (IAEConcept *)findConceptOfCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPathOfCell = [self.conceptsCollectionView indexPathForCell:cell];
    return [self findConceptAtIndexPath:indexPathOfCell];
}

- (IAEContextView *)findActualSelectedMonthContextView
{
    NSAssert(self.contextMenuView.currentOptionIndexSelected > 0, @"");
    return [self findContextViewAtGlobalPosition:self.contextMenuView.currentOptionIndexSelected];
}

- (IAEContextView *)findOpenYearContextView
{
    return [self findContextViewAtGlobalPosition:0];
}

- (IAEContextView *)findContextViewAtGlobalPosition:(NSUInteger)globalPosition
{
    UIView *contextView = [self.contextScrollView.subviews objectAtIndex:globalPosition];
    
    return (IAEContextView *)contextView;
}

- (BOOL)categorySelectorViewControllerWasLaunchedFromCategoryButton
{
    // Nota: Solo tendra sentido si realmente se ha lanzado
    return self.popover == nil;
}

- (IAEContextView *)findActualSelectedContext
{
    IAEContextView *actualSelectedContext = nil;
    if ([self isActualSelectedContextAMonth]) {
        actualSelectedContext = [self findActualSelectedMonthContextView];
    } else {
        actualSelectedContext = [self findContextViewAtGlobalPosition:kGlobalIndexForYearInContextScrollView];
    }
    
    return actualSelectedContext;
}

- (NSArray *)findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSArray *categories = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:type];

    return categories;
}

- (NSUInteger)findDayOfTheMonthForConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    return concept.dayOfTheMonth;
}

#pragma mark - Update 

- (void)updateBalancesWithAnimation:(BOOL)animation
{
    [self updateSelectedMonthBalanceWithAnimation:animation];
    [self updateOpenYearBalance];
}

- (void)updateSelectedMonthBalanceWithAnimation:(BOOL)animation
{
    IAEContextView *contextView = [self findActualSelectedMonthContextView];
    [contextView reloadDataWithAnimation:animation];
}

- (void)updateOpenYearBalance
{
    IAEContextView *contextView = [self findOpenYearContextView];
    [contextView reloadDataWithAnimation:NO];
}

- (void)processEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration
{
}

#pragma mark - CalculatorViewController (vincule)

- (void)vinculeCalculatorViewControllerView
{
    self.calculatorViewController.view.frame = CGRectMake(0,
                                                          0,
                                                          self.calculatorViewController.view.bounds.size.width,
                                                          self.calculatorViewController.view.bounds.size.height);
    
    CGFloat centerY = self.view.frame.size.height +
                      self.calculatorViewController.view.bounds.size.height / 2 -
                      self.calculatorViewController.sizeHeightOfDragPanel;
    self.calculatorViewController.view.center = CGPointMake(self.view.center.x, centerY);
    
    [self.view addSubview:self.calculatorViewController.view];
}

#pragma mark - AnnualBalance (vincule)

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
    [self performActionsAfterDismissPopover:self.popover];
}

#pragma mark - ScrollViewMonths (vincule)

- (void)vinculeContextScrollViewContent
{
    [self addToContextScrollViewContextWithGlobalPosition:0 contextType:CONTEXT_VIEW_YEAR andValueIndex:[self findOpenYear].yearDate];
    [self addToContextScrollViewContextWithGlobalPosition:1 contextType:CONTEXT_VIEW_MONTH andValueIndex:January];
    [self addToContextScrollViewContextWithGlobalPosition:2 contextType:CONTEXT_VIEW_MONTH andValueIndex:February];
    [self addToContextScrollViewContextWithGlobalPosition:3 contextType:CONTEXT_VIEW_MONTH andValueIndex:March];
    [self addToContextScrollViewContextWithGlobalPosition:4 contextType:CONTEXT_VIEW_MONTH andValueIndex:April];
    [self addToContextScrollViewContextWithGlobalPosition:5 contextType:CONTEXT_VIEW_MONTH andValueIndex:May];
    [self addToContextScrollViewContextWithGlobalPosition:6 contextType:CONTEXT_VIEW_MONTH andValueIndex:June];
    [self addToContextScrollViewContextWithGlobalPosition:7 contextType:CONTEXT_VIEW_MONTH andValueIndex:July];
    [self addToContextScrollViewContextWithGlobalPosition:8 contextType:CONTEXT_VIEW_MONTH andValueIndex:August];
    [self addToContextScrollViewContextWithGlobalPosition:9 contextType:CONTEXT_VIEW_MONTH andValueIndex:September];
    [self addToContextScrollViewContextWithGlobalPosition:10 contextType:CONTEXT_VIEW_MONTH andValueIndex:October];
    [self addToContextScrollViewContextWithGlobalPosition:11 contextType:CONTEXT_VIEW_MONTH andValueIndex:November];
    [self addToContextScrollViewContextWithGlobalPosition:12 contextType:CONTEXT_VIEW_MONTH andValueIndex:December];
    
    self.contextScrollView.delegate = self;
}

- (void)addToContextScrollViewContextWithGlobalPosition:(NSUInteger)globalPosition
                                            contextType:(IAEContextViewType)contextType
                                          andValueIndex:(NSUInteger)contextValueIndex
{
    CGRect frame = CGRectMake(self.contextScrollView.bounds.size.width * globalPosition,
                              0,
                              self.contextScrollView.bounds.size.width,
                              self.contextScrollView.bounds.size.height);
    IAEContextView *contextView = [[IAEContextView alloc] initWithFrame:frame type:contextType andValueIndex:contextValueIndex];
    contextView.dataSource = self;
    [contextView reloadDataWithAnimation:NO];
    
    [self.contextScrollView addSubview:contextView];
}

#pragma mark - UIPopoverControllerViewDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self performActionsAfterDismissPopover:popoverController];
}

- (void)performActionsAfterDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController.contentViewController isKindOfClass:[IAEAdjustConceptAmountViewController class]]) {
        [self updateBalancesWithAnimation:YES];
    } else if ([popoverController.contentViewController isKindOfClass:[IAEDayCalendarSelectorViewController class]]) {
        [self cleanDayCalendarSelectorProperties];
    }
    
    self.popover = nil;
}

- (void)updateBalancesIfDismissFromAdjustConceptAmountPopover:(UIPopoverController *)popover
{
    if ([popover.contentViewController isKindOfClass:[IAEAdjustConceptAmountViewController class]]) {
        [self updateBalancesWithAnimation:YES];
    }
}

- (void)cleanDayCalendarSelectorProperties
{
    self.conceptChangingDay = nil;
}

#pragma mark - UIScrollView Delegate

- (BOOL)isContextScrollView:(UIScrollView *)scrollView
{
    BOOL contextScrollView = scrollView == self.contextScrollView;
    
    return contextScrollView;
}

- (BOOL)isReportScrollView:(UIScrollView *)scrollView
{
    BOOL reportScrollView = scrollView == (UIScrollView *)self.reportAreaView;
    
    return reportScrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self isContextScrollView:scrollView]) {
        [self contextScrollViewDidScroll];
    }
}

- (void)contextScrollViewDidScroll
{
    [self updateCurrentOptionIndexSelectedOfContextMenu];
    if ([self isEditModeActive]) {
        [self updateContentOfConceptsCollectionView];
        [self setConceptsCollectionViewInTransitionAspect:NO];
        [self updateCalculatorViewHideHalfState];
    } else if ([self isReportModeActive]) {
        [self.reportAreaView reloadData];
    }
}

- (void)setConceptsCollectionViewInTransitionAspect:(BOOL)transition
{
    [UIView animateWithDuration:0.25 animations:^{
        self.conceptsCollectionView.alpha = transition ? 0.15 : 1.0;
    }];
}

- (void)updateCurrentOptionIndexSelectedOfContextMenu
{
    CGFloat currentOptionIndex = (self.contextScrollView.contentOffset.x / self.contextScrollView.bounds.size.width) + 0.5;
    self.contextMenuView.currentOptionIndexSelected = floor(currentOptionIndex);
}

- (void)updateCalculatorViewHideHalfState
{
    if ([self isActualSelectedContextTheYearOpen]) {
        [self.calculatorViewController disable];
    } else {
        [self.calculatorViewController enable];
    }
}

- (BOOL)isHideHalfCalculatorViewEnabled
{
    return YES;
}

- (void)updateContentOfConceptsCollectionView
{
    [self.conceptsCollectionView reloadData];
    if ([self.conceptsCollectionView numberOfItemsInSection:0] > 0) {
        [self.conceptsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionNone
                                                    animated:NO];
    }
}

#pragma mark - IAEContextViewDataSource

- (NSString *)nameForContextView:(IAEContextView *)contextView
{
    NSString *name = nil;
    
    IAEYear *year = [self findOpenYear];
    if (contextView.contextType == CONTEXT_VIEW_MONTH) {
        IAEMonth *month = [year.ordererMonths objectAtIndex:contextView.valueIndex - 1];
        name = [month description];
    } else if (contextView.contextType == CONTEXT_VIEW_YEAR) {
        name = [year yearDateAsString];
    }
    
    return name;
}

- (NSDecimalNumber *)balanceForContextView:(IAEContextView *)contextView
{
    NSDecimalNumber *balance = nil;
    
    IAEYear *openYear = [self findOpenYear];
    if (contextView.contextType == CONTEXT_VIEW_MONTH) {
        IAEMonth *month = [openYear.ordererMonths objectAtIndex:contextView.valueIndex - 1];
        balance = [month balance];
    } else if (contextView.contextType == CONTEXT_VIEW_YEAR) {
        balance = [openYear balance];
    }
    
    return balance;
}

- (IAEMonth *)findForOpenYearMonthAtIndex:(NSUInteger)monthIndex
{
    NSAssert(monthIndex >= 0, @"");
    NSAssert(monthIndex < kNumberOfMonths, @"");
    IAEYear *year = [self findOpenYear];
    IAEMonth *month = [year.ordererMonths objectAtIndex:monthIndex];

    return month;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeZero;
    if ([self isActualSelectedContextTheYearOpen]) {
        // ToDo: Mal, esto deberia de cogerse directamente del xib
        headerSize = CGSizeMake(910, 50);
    }
    
    return headerSize;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell == self.conceptCellToRemove) {
        [self.strokeAnimatableLineView resetStroke];
        self.conceptCellToRemove = nil;
        [self updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsIfAppropriateBeforeIndexPath:indexPath];
    }
}

- (void)updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsIfAppropriateBeforeIndexPath:(NSIndexPath *)indexPathLimit
{
    if (![self isDayModeActiveForConcepts]) {
        [self updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsBeforeIndexPath:indexPathLimit];
    }
}

- (void)updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsBeforeIndexPath:(NSIndexPath *)indexPathLimit
{
    NSInteger cellUpdateCounter = 0;
    NSUInteger numberOfItems = [self findNumberOfConceptsOfActualSelectedContext:indexPathLimit.section];
    for (IAEEditModeConceptCollectionViewCell *cellVisible in self.conceptsCollectionView.visibleCells) {
        NSIndexPath *indexPathOfVisibleCell = [self.conceptsCollectionView indexPathForCell:cellVisible];
        if (indexPathOfVisibleCell.row < indexPathLimit.row) {
            NSUInteger instantEntryIndex =  numberOfItems - indexPathOfVisibleCell.row;
            CGFloat animationDuration = KDurationOfAnimationUpdateForEntryInstantIndex + 0.25 * cellUpdateCounter++;
            [cellVisible setIdentifierWithEntryInstantIndex:instantEntryIndex withAnimationDuration:animationDuration];
        }
    }
}

- (NSArray *)findItemsAtIndexPathFromIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger rowIt = indexPath.row - 1; rowIt > 0; rowIt--) {
        [items addObject:[NSIndexPath indexPathForRow:rowIt inSection:indexPath.section]];
    }
    
    return [NSArray arrayWithArray:items];
}

#pragma mark - IAEStrokeAnimatableLineViewDelegate

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view
{
    [self performSelector:@selector(doRemoveConceptCellToRemove) withObject:nil afterDelay:kDelayToExecuteRemoveConceptCell];
}

- (void)doRemoveConceptCellToRemove
{
    [self removeConceptAndUpdateBalancesOfCell:self.conceptCellToRemove withAnimation:YES];
}

#pragma mark - UISwipeGestureRecognizer

- (void)swipeOnConceptsCollectionView:(UIGestureRecognizer *)swipeGestureRecognizer
{
    if ([self isActualSelectedContextAMonth]) {
        self.conceptCellToRemove = [self findConceptCellUnderLocationOfGestureRecognizer:swipeGestureRecognizer];
        self.conceptCellToRemove.durationOfStrokeStateTransition = self.strokeAnimatableLineView.durationOfStrokeAnimation;
        [self.strokeAnimatableLineView doStrokeOverTheView:self.conceptCellToRemove.conceptInformationContainerView];
        [self.conceptCellToRemove goToStrokeState];
    }
}

#pragma mark - UITapGestureRecognizer

- (void)tapOnConceptsCollectionView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSAssert(tapGestureRecognizer == self.tapConceptsRecognizer, @"");
    if ([self isActualSelectedContextAMonth]) {
        [self findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:tapGestureRecognizer];
    }
}

- (void)findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:tapGestureRecognizer];
    [self executeActionOnCellOfConceptCollectionView:cell underLocatonOfTapGestureRecognizer:tapGestureRecognizer];
}

- (IAEEditModeConceptCollectionViewCell *)findConceptCellUnderLocationOfGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.conceptsCollectionView];
    NSIndexPath *locationIndexPath = [self.conceptsCollectionView indexPathForItemAtPoint:location];
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:locationIndexPath];
    
    return cell;
}

- (void)executeActionOnCellOfConceptCollectionView:(IAEEditModeConceptCollectionViewCell *)cell
                   underLocatonOfTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [self convertLocationToCellArea:cell fromGestureRecognizer:gestureRecognizer];
    
    if ([cell isAmountLabelContainingLocationPoint:location]) {
        [self openPopoverForAdjustAmountOfConceptCell:cell];
    } else if ([cell isCategoryNameOrTypeContainingLocationPoint:location]) {
        [self openPopoverForEditCategoryOfConceptCell:cell];
    } else if ([cell isIdentifierOrDayContainingLocationPoint:location] && [self isDayModeActiveForConcepts]) {
        [self openPopoverForSelectDayOfConceptCell:cell];
    }
}

- (CGPoint)convertLocationToCellArea:(UICollectionViewCell *)cell fromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.conceptsCollectionView];;
    CGPoint locationConvertedToCellArea = [cell convertPoint:location fromView:self.conceptsCollectionView];

    return locationConvertedToCellArea;
}

- (void)openPopoverForAdjustAmountOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{    
    IAEAdjustConceptAmountViewController *viewController = [[IAEAdjustConceptAmountViewController alloc] init];
    viewController.delegate = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];

    [self createAndPresentPopoverForConceptCellView:cell.amountLabel withViewController:viewController];
}

- (void)openPopoverForEditCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
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

- (void)openPopoverForSelectDayOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    self.conceptChangingDay = [self findConceptOfCell:cell];
    
    IAEYear *year = [self findOpenYear];
    IAEMonth *month = [self findActualSelectedMonth];
    NSUInteger selectedDay = [self findDayOfTheMonthForConceptCell:cell];
    
    IAEDayCalendarSelectorViewController *viewController = [[IAEDayCalendarSelectorViewController alloc] initWithYearDate:year.yearDate
                                                                                                               monthIndex:month.month
                                                                                                           andDaySelected:selectedDay];
    viewController.delegate = self;
    
    [self createAndPresentPopoverForConceptCellView:cell.identifierContainerView withViewController:viewController];
}

- (void)removeConceptAndUpdateBalancesOfCell:(UICollectionViewCell *)cell withAnimation:(BOOL)animation
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAEMonth *month = [self findActualSelectedMonth];
    [month removeConcept:concept];
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView deleteItemsAtIndexPaths:@[[self.conceptsCollectionView indexPathForCell:cell]]];
    [self updateBalancesWithAnimation:YES];
}

#pragma mark - IAEAdjustConceptAmountViewControllerDelegate

- (void)adjustConceptsAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptsAmountViewController
          didPressedAdjustButtonWithAmount:(NSNumber *)amount
{
    [self modifyAmmountOfConceptOfCellIndexPath:adjustConceptsAmountViewController.conceptCellIndexPath byAddingAmmount:amount];
}

- (void)modifyAmmountOfConceptOfCellIndexPath:(NSIndexPath *)cellIndexPath byAddingAmmount:(NSNumber *)amount
{
    IAEConcept *concept = [self findConceptAtIndexPath:cellIndexPath];
    
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:cellIndexPath];
    
    if ([self updateWithNewAbsoluteValueOfConcept:concept byAdding:amount]) {
        [self.helperConceptsCollectionViewDataSource configureEditModeConceptCell:cell withConceptAtIndexPath:cellIndexPath];
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
        [self.helperConceptsCollectionViewDataSource configureEditModeConceptCell:cell withConceptAtIndexPath:indexPath];

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
    // ToDo: Valorar que la creacion se realice en el editor de categorias para factorizar en un unico sitio la creacion
    IAECategory *newCategory = [[IAECategoryStore sharedCategoryStore] createCategoryOfType:categoryType andTag:categoryTag withValidityTagCheck:NO];
    NSAssert(newCategory, @"");
    [[IAEBook sharedBook] saveAll];
    
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
    [self reloadAllWithAnimation:NO];
    [self goToTodayMonth];
}

- (void)reloadAllWithAnimation:(BOOL)animation
{
    [self reloadBalancesOfContextViewsWithAnimation:animation];
    [self reloadConceptsOfActualSelectedContextView];
}

- (void)reloadAllAndGoToTodayMonthWithAnimation:(BOOL)animation
{
    [self reloadAllWithAnimation:animation];
    [self goToTodayMonth];
}

- (void)reloadBalancesOfContextViewsWithAnimation:(BOOL)animation
{
    for (UIView *view in self.contextScrollView.subviews) {
        if ([view isKindOfClass:[IAEContextView class]]) {
            IAEContextView *contextView = (IAEContextView *)(view);
            [contextView reloadDataWithAnimation:animation];
        }
    }
}

- (void)reloadConceptsOfActualSelectedContextView
{
    [self.conceptsCollectionView reloadData];
}

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didCreateAndLoadSelectedYearDate:(NSUInteger)yearDate
{
    [self reloadAllAndGoToTodayMonthWithAnimation:NO];
}

- (void)closeButtonWasPressedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    [self reloadAllAndGoToTodayMonthWithAnimationIfOpenYearWasCleanInYearSelector];
}

- (void)reloadAllAndGoToTodayMonthWithAnimationIfOpenYearWasCleanInYearSelector
{
    if (self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate) {
        [self reloadAllAndGoToTodayMonthWithAnimation:NO];
        self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate = NO;
    }
}

- (void)openYearSelectedWasSelectedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    [self reloadAllAndGoToTodayMonthWithAnimationIfOpenYearWasCleanInYearSelector];
}

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didCleanOpenYearDate:(NSUInteger)yearDate
{
    // Nota: Este evento informa de que se ha vaciado el año abiertopero que aun no se ha cerrado el dialogo selector, es decir, la recarga
    // de datos sucedera si y solo si, se retorna al mismo año abierto antes de abrir la venta de seleccion de años
    self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate = YES;
}

- (BOOL)isOpenYearEqualToYearDate:(NSUInteger)yearDate
{
    return yearDate == [self findOpenYear].yearDate;
}

#pragma mark - Notification Center

- (void)notificationCenterOnDayModeOn:(NSNotification *)notification
{
    [self.conceptsCollectionView reloadData];
}

- (void)notificationCenterOnDayModeOff:(NSNotification *)notification
{
    [self.conceptsCollectionView reloadData];
}

#pragma mark - IAEDayCalendarSelectorViewControllerDelegate

- (void)dayCalendarSelectorViewController:(IAEDayCalendarSelectorViewController *)dayCalendarSelectorViewController
                             didSelectDay:(NSUInteger)day
{
    [self updateConceptChangingDayWithDay:day];
    [self dismisPopover];
}

- (void)updateConceptChangingDayWithDay:(NSUInteger)day
{
    NSAssert(self.conceptChangingDay, @"");
    if (self.conceptChangingDay.dayOfTheMonth != day) {
        self.conceptChangingDay.dayOfTheMonth = day;
        [[IAEBook sharedBook] saveAll];
        [self.conceptsCollectionView reloadData];
    }
}

#pragma mark - IAECalculatorViewControllerDelegate

- (void)showButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [UIView animateWithDuration:0.25 animations:^{
        [self updateFramePositionBeforeShowCalculatorForView:self.contextScrollView];
        [self updateFramePositionBeforeShowCalculatorForView:self.contextMenuView];
        [self updateFramePositionBeforeShowCalculatorForView:self.modeSegmentedControl];
        [self updateFramePositionBeforeShowCalculatorForView:self.editAndReportModeContentContainerView];
    }];
}

- (void)hideButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [UIView animateWithDuration:0.25 animations:^{
        [self updateFramePositionAfterShowCalculatorForView:self.contextScrollView];
        [self updateFramePositionAfterShowCalculatorForView:self.contextMenuView];
        [self updateFramePositionAfterShowCalculatorForView:self.modeSegmentedControl];
        [self updateFramePositionAfterShowCalculatorForView:self.editAndReportModeContentContainerView];
    }];
}

- (void)updateFramePositionBeforeShowCalculatorForView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y - self.calculatorViewController.sizeHeightOffsetWhenShowed,
                            view.frame.size.width,
                            view.frame.size.height);
}

- (void)updateFramePositionAfterShowCalculatorForView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y + self.calculatorViewController.sizeHeightOffsetWhenShowed,
                            view.frame.size.width,
                            view.frame.size.height);
}

#pragma mark - IAECalculatorViewControllerDelegate

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept
{
    [self.conceptsCollectionView reloadData];
    [self updateBalancesWithAnimation:NO];
}

#pragma mark - IAETextRawSelectorMenuViewDelegate

- (void)optionIndex:(NSUInteger)optionIndex wasSelectedInTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        [self gotoToContextViewWithIndex:optionIndex];
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        [self.reportAreaView reloadData];
    }
}

- (BOOL)isTheContextMenuTheTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    BOOL isContextMenu = textRawSelectorMenu == self.contextMenuView;
    
    return isContextMenu;
}

- (BOOL)isTheReportMenuTheTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    BOOL isReportMenu = textRawSelectorMenu == self.reportMenuView;
    
    return isReportMenu;
}

@end
