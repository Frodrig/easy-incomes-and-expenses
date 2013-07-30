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
#import "NSNumber+DefaultValues.h"
#import "IAECategoryStore.h"
#import "IAEDateHelper.h"
#import "UIView+LoadFromXib.h"
#import "UIView+RoundedCorners.h"
#import "NSDecimalNumber+AbsoluteValue.h"

@interface IAEEasyIncomesAndExpensesViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *contextScrollView;
@property (weak, nonatomic) IBOutlet UIView *editAndReportModeContentContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;
@property (nonatomic, strong) IAEReportAreaView *reportAreaView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *contextMenuView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *reportMenuView;
@property (nonatomic, strong) IAECalculatorViewController *calculatorViewController;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UITapGestureRecognizer *tapConceptsRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *dobleTapConceptsRecognizer;
@property (nonatomic) BOOL initialPositioning;
@property (nonatomic, weak) IAECategory *categoryRenaming;
@property (nonatomic, weak) IAEConcept *conceptChangingDay;
@property (nonatomic) BOOL reloadAllPendingFromYearSelectorIfReturnWithSameYearDate;

@end

@implementation IAEEasyIncomesAndExpensesViewController

#pragma mark - Constants

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

static NSString * const kContextMenuFontFamilyName = @"HelveticaNeue-Ultralight";
static const CGFloat kContextMenuFontSizeOfOptions = 24;
static const CGFloat kContextMenuDefaultKernOfOptions = 4;
static const CGFloat kContextMenuYearKernOfOptions = 0;
static const NSUInteger kContextMenuIndexOfYearOption = 0;

static const NSUInteger kSegmentedControlIndexEditMode = 0;
static const NSUInteger kSegmentedControlIndexReportMode = 1;

static const NSUInteger kReportMenuNumberOfItems = 3;
static NSString * const kReportMenuFontFamilyName = @"HelveticaNeue-Ultralight";
static const CGFloat kReportMenuFontSizeOfOptions = 28;
static const CGFloat kReportMenuKernOfOptions = 4;
static const CGFloat kReportMenuItemWidthSize = 200;
static const NSUInteger kReportMenuIndexOfBalancesOption = 0;
static const NSUInteger kReportMenuIndexOfIncomesOption = 1;
static const NSUInteger kReportMenuIndexOfExpensesOption = 2;

static NSString * const kLtextIncomeCategoryTypeName = @"LTEXT_CATEGORYTYPEINCOME_NAME";
static NSString * const kLtextExpenseCategoryTypeName = @"LTEXT_CATEGORYTYPEEXPENSE_NAME";

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommonProperties];
        [self initDobleTapConceptsGestureRecognizer];
        [self initTapConceptsGestureRecognizer];
        [self initAsObserverOfNotificationCenter];
        [self initContextMenuView];
        [self initCalculatorViewController];
        [self initReportAreaView];
        [self initReportMenuView];
    }
    
    return self;
}

- (void)initCommonProperties
{
    self.initialPositioning = YES;
}

- (void)initDobleTapConceptsGestureRecognizer
{
    _dobleTapConceptsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dobleTapConceptsCollectionView:)];
    _dobleTapConceptsRecognizer.numberOfTapsRequired = 2;
}

- (void)initTapConceptsGestureRecognizer
{
    _tapConceptsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnConceptsCollectionView:)];
    _tapConceptsRecognizer.numberOfTapsRequired = 1;
    
    [_tapConceptsRecognizer requireGestureRecognizerToFail:_dobleTapConceptsRecognizer];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.conceptsCollectionView removeGestureRecognizer:self.tapConceptsRecognizer];
    [self.conceptsCollectionView removeGestureRecognizer:self.dobleTapConceptsRecognizer];
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
    _calculatorViewController.dataSource = self;
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
    
    self.conceptsCollectionView.backgroundColor = [UIColor clearColor];
    self.conceptsCollectionView.showsHorizontalScrollIndicator = NO;
    self.conceptsCollectionView.showsVerticalScrollIndicator = NO;
    
    [self.conceptsCollectionView addGestureRecognizer:self.tapConceptsRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.dobleTapConceptsRecognizer];
}

- (void)configureReportAreaView
{
    self.reportAreaView.backgroundColor = [UIColor clearColor];
}

- (void)configureReportMenuView
{
    _reportMenuView.backgroundColor = [UIColor clearColor];
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
    self.conceptsCollectionView.dataSource = self;
}

- (void)vinculeContextMenuView
{
    [self.view addSubview:_contextMenuView];
    self.contextMenuView.delegate = self;
    self.contextMenuView.dataSource = self;
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
    self.reportMenuView.dataSource = self;
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
    self.reportAreaView.dataSource = self;
    self.reportAreaView.delegate = self;
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

- (IAEYear *)findOpenYear
{
    return [[IAEBook sharedBook] findActualYear];
}

- (IAEMonth *)findMonthOfPresentDay
{
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
    return [self findMonthForOpenYearAtIndex:todayMonthIndex];
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

- (IAEMonth *)findMonthForOpenYearAtIndex:(NSUInteger)index
{
    IAEYear *year = [self findOpenYear];
    return [year.ordererMonths objectAtIndex:index];
}

- (NSArray *)allConceptsSortedAsAppropriateFromActualSelectedContext
{
    NSArray *allConcepts = nil;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *actualMonth = [self findActualSelectedMonth];
        allConcepts = [self isDayModeActiveForConcepts] ? [actualMonth  allConceptsSortedByDay] : [actualMonth allConceptsSortedByEntryInstant];
    } else {
        IAEYear *openYear = [self findOpenYear];
        allConcepts = [self isDayModeActiveForConcepts] ? [openYear findAllConceptsSortedByDay] : [openYear findAllConceptsSortedByEntryInstant];
    }
    
    return allConcepts;
}

- (BOOL)isDayModeActiveForConcepts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

- (IAEConcept *)findConceptAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *concepts = [self allConceptsSortedAsAppropriateFromActualSelectedContext];
    IAEConcept *concept = [concepts objectAtIndex:indexPath.row];
    
    return concept;
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

- (NSUInteger)findNumberOfConceptsOfActualSelectedContext
{
    NSUInteger numberOfConcepts = 0;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *month = [self findActualSelectedMonth];
        numberOfConcepts = month.concepts.count;
    } else {
        IAEYear *year = [self findOpenYear];
        numberOfConcepts = [year findAllConcepts].count;
    }
    
    return numberOfConcepts;
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

- (NSArray *)findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSArray *categories = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:type];

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

- (NSString *)findDayOfTheWeekNameFromConcept:(IAEConcept *)concept
{
    NSUInteger dayOfTheWeekIndex = [IAEDateHelper findDayOfTheWeekIndexFromYearDate:concept.month.year.yearDate
                                                                         monthIndex:concept.month.month
                                                                   andDayOfTheMonth:concept.dayOfTheMonth];
    NSString *dayOfTheWeekName = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:dayOfTheWeekIndex inShortForm:NO];
    
    return dayOfTheWeekName;
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
        [self.conceptsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
    NSAssert(monthIndex < 12, @"");
    IAEYear *year = [self findOpenYear];
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
    NSUInteger numberOfItems = [self findNumberOfConceptsOfActualSelectedContext];

    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(collectionView == self.conceptsCollectionView, @"Se ha recibido una collection view no esperada");
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdConceptCellName forIndexPath:indexPath];
    
    [self configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:(NSIndexPath *)indexPath
{
    // Nota: Por defecto los conceptos tienen el valor absoluto de la cantidad que almacenan de ahi el pedir la cantidad con signo si procede
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    NSAssert(concept, @"");
    IAECategory *category = concept.category;
    NSAssert(category, @"");
    NSDecimalNumber *amountWithSign = [concept amountWithSign];
    NSString *amountWithSignString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:amountWithSign];
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    UIColor *colorForEconomicValueType = [IAEColorHelper colorForEconomicValueType:economicValueType];
    NSUInteger instantEntryIndex = [self findNumberOfConceptsOfActualSelectedContext] - indexPath.row;

    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    [self configureCategoryLabelsOfConceptCell:cell withCategory:category];
    [self configureAmountLabelOfConceptCell:cell withAmountWithSignString:amountWithSignString andColor:colorForEconomicValueType];
    [self configureIdentifierOfConceptCell:cell atIndexPath:indexPath withIndex:instantEntryIndex];
}

- (void)configureCategoryLabelsOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                                withCategory:(IAECategory *)category
{
    NSDictionary *categoryNameLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptNameLabelInConceptCell]
                                                                                              andColor:[UIColor blackColor]];
    cell.categoryNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag]
                                                                            attributes:categoryNameLabelAttributes];
    
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

- (void)configureIdentifierOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath
                               withIndex:(NSUInteger)index
{
    if (![self isDayModeActiveForConcepts]) {
        [cell setIdentifierWithEntryInstantIndex:index];
    } else if ([self isDayOfTheMonthAssociatedWithConceptCell:cell atIndexPath:indexPath]) {
        [self setIdentifierForDayOfTheMonthAndDayOfTheWeekNameForCell:cell atIndexPath:indexPath withIndex:index];
    } else {
        [cell setIdentifierWithoutDay];
    }
}

- (BOOL)isDayOfTheMonthAssociatedWithConceptCell:(IAEEditModeConceptCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    return concept.dayOfTheMonth != 0;
}

- (void)setIdentifierForDayOfTheMonthAndDayOfTheWeekNameForCell:(IAEEditModeConceptCollectionViewCell *)cell
                                                    atIndexPath:(NSIndexPath *)indexPath
                                                      withIndex:(NSUInteger)index
{
    IAEConcept *concept = [self findConceptAtIndexPath:indexPath];
    NSString *dayOfTheWeekName = [self findDayOfTheWeekNameFromConcept:concept];
    
    [cell setIdentifierWithDayOfTheMonthIndex:concept.dayOfTheMonth andDayOfTheWeekName:dayOfTheWeekName];
}

#pragma mark - UICollectionView Delegate

#pragma mark - UITapGestureRecognizer

- (void)tapOnConceptsCollectionView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSAssert(tapGestureRecognizer == self.tapConceptsRecognizer, @"");
    if ([self isActualSelectedContextAMonth]) {
        [self findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:tapGestureRecognizer];
    }
}

- (void)dobleTapConceptsCollectionView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSAssert(tapGestureRecognizer == self.dobleTapConceptsRecognizer, @"");
    if ([self isActualSelectedContextAMonth]) {
        [self findCellOfConceptsCollectionViewAndExecuteActionUnderDobleTapGesture:tapGestureRecognizer];
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

- (void)findCellOfConceptsCollectionViewAndExecuteActionUnderDobleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:tapGestureRecognizer];
    if (cell) {
        [self removeConceptAndUpdateBalancesOfCell:cell withAnimation:YES];
    }
}

- (void)removeConceptAndUpdateBalancesOfCell:(UICollectionViewCell *)cell withAnimation:(BOOL)animation
{
    NSAssert(cell, @"");
    
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAEMonth *month = [self findActualSelectedMonth];
    [month removeConcept:concept];
    
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView reloadData];
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

#pragma mark - IAECalculatorViewControllerDataSource

- (IAEYear *)yearForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    return [self findOpenYear];
}

- (IAEMonth *)monthForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    return [self findActualSelectedMonth];
}

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept
{
    [self.conceptsCollectionView reloadData];
    [self updateBalancesWithAnimation:NO];
}

#pragma mark - IAETextRawSelectorMenuViewDataSource

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

- (NSUInteger)numberOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSUInteger numberOfOptions = 0;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        numberOfOptions = kContentScrollViewNumberOfItems;
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        numberOfOptions = kReportMenuNumberOfItems;
    }

    return numberOfOptions;
}

- (NSString *)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu optionStringNameAtIndex:(NSUInteger)optionIndex
{
    NSString *optionStringName = nil;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        if (optionIndex == kContextMenuIndexOfYearOption) {
            optionStringName = [NSString stringWithFormat:@"%d", [self findOpenYear].yearDate];
        } else {
            optionStringName = [IAEDateHelper findMonthNameStringWithMonthIndex:optionIndex inShortForm:YES];
        }
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        static NSArray *menuOptionsName = nil;
        if (menuOptionsName == nil) {
            menuOptionsName = @[NSLocalizedString(@"LTEXT_MENUOPTIONSREPORT_OPTIONBALANCE", @""),
                                NSLocalizedString(@"LTEXT_MENUOPTIONSREPORT_OPTIONINCOMES", @""),
                                NSLocalizedString(@"LTEXT_MENUOPTIONSREPORT_OPTIONEXPENSES", @"")];
        }
        optionStringName = [menuOptionsName objectAtIndex:optionIndex];
    }
    
    return optionStringName;
}

- (UIColor *)colorForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    return [UIColor blackColor];
}

- (CGSize)sizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGSize size = CGSizeZero;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        CGFloat width = self.view.bounds.size.width / kContentScrollViewNumberOfItems;
        size = CGSizeMake(width, 44);
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        size = CGSizeMake(kReportMenuItemWidthSize, 44);
    }

    return size;
}

- (NSString *)fontFamilyNameOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSString *fontFamily = nil;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        fontFamily = kContextMenuFontFamilyName;
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        fontFamily = kReportMenuFontFamilyName;
    }

    return fontFamily;
}

- (CGFloat)fontSizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGFloat fontSize = 0;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        fontSize = kContextMenuFontSizeOfOptions;
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        fontSize = kReportMenuFontSizeOfOptions;
    }

    return fontSize;
}

- (CGFloat)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu kernOfOptionsAtIndex:(NSUInteger)optionIndex
{
    CGFloat kern = 0;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        kern = kContextMenuDefaultKernOfOptions;
        if (optionIndex == kContextMenuIndexOfYearOption) {
            kern = kContextMenuYearKernOfOptions;
        }
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        kern = kReportMenuKernOfOptions;
    }
    
    return kern;
}

- (IAETextRawSelectorMenuViewSelectorType)selectorTypeInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    IAETextRawSelectorMenuViewSelectorType selectorType = TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        selectorType = TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR;
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        selectorType = TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR;
    }

    return selectorType;
}

- (UIColor *)colorForSelectorIndicatorInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    UIColor *color = nil;
    
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        color = [UIColor colorWithWhite:0.9 alpha:0.3];
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        color = [UIColor colorWithWhite:0.9 alpha:0.3];
    }
    
    return color;
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

#pragma mark - IAEReportAreaViewDataSource

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
    BOOL isSelected = optionIndex == self.reportMenuView.currentOptionIndexSelected;
    
    return isSelected;
}

- (NSUInteger)numberOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    NSUInteger number = 0;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        return 2;
    } else if ([self isTheIncomesOptionSelectedInReportMenu]) {
        number = [self findIncomesCategoriesOfActualSelectedContextView].count;
    } else if ([self isTheExpensesOptionSelectedInReportMenu]) {
        number = [self findExpensesCategoriesOfActualSelectedContextView].count;
    }
    
    return number;
}

- (CGFloat)maxValueOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    // ToDo: Ojo, mas que float deberiamos de pensar en long long double
    CGFloat maxValue = 0;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        NSDecimalNumber *incomes = [self findIncomesOfActualSelectedContextView];
        NSDecimalNumber *expenses = [self findExpensesOfActualSelectedContextView];
        maxValue = [[self maxValueOfNumber:incomes andNumber:expenses] floatValue];
    } else {
        NSDecimalNumber *maxDecimalValue = [self findMaxValueOfAllCategoriesForActualSelectedContext];
        maxValue = maxDecimalValue.floatValue;
    }
    
    return maxValue;
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

- (NSDecimalNumber *)maxValueOfNumber:(NSDecimalNumber *)numberOne andNumber:(NSDecimalNumber *)numberTwo
{
    NSDecimalNumber *maxValue = [numberOne compare:numberTwo] == NSOrderedDescending ? numberOne : numberTwo;
    
    return maxValue;
}

- (UIColor *)reportAreaView:(IAEReportAreaView *)reportAreaView colorRepresentationOfItemWithIndex:(NSUInteger)itemIndex
{
    UIColor *color = nil;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        color = itemIndex == 0 ? [IAEColorHelper colorForEconomicIncomeValue] : [IAEColorHelper colorForEconomicExpenseValue];
    } else if ([self isTheIncomesOptionSelectedInReportMenu]) {
        color = [IAEColorHelper colorForEconomicIncomeValue];
    } else if ([self isTheExpensesOptionSelectedInReportMenu]) {
        color = [IAEColorHelper colorForEconomicExpenseValue];
    }
    
    return color;
}

- (CGFloat)reportAreaView:(IAEReportAreaView *)reportAreaView valueOfItemWithIndex:(NSUInteger)itemIndex
{
    // ToDo: Ojo, mas que float deberiamos de pensar en long long double
    CGFloat valueOfItem = 0;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        NSDecimalNumber *decimalValue = itemIndex == 0 ? [self findIncomesOfActualSelectedContextView] : [self findExpensesOfActualSelectedContextView];
        valueOfItem = [decimalValue floatValue];
    } else {
        NSArray *categories = [self isTheIncomesOptionSelectedInReportMenu] ? [self findIncomesCategoriesOfActualSelectedContextView] :
                                                                              [self findExpensesCategoriesOfActualSelectedContextView];
        IAECategory *category = categories[itemIndex];
        id modelObj = [self findModelObjectOfActualSelectedContextView];
        NSDecimalNumber *balance = [modelObj balanceOfAllConceptsOfCategory:category];
        valueOfItem = [balance floatValue];
    }
    
    return valueOfItem;
}

- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView titleOfItemWithIndex:(NSUInteger)itemIndex
{
    NSString *title = nil;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        NSDecimalNumber *value = itemIndex == 0 ? [self findIncomesOfActualSelectedContextView] : [self findExpensesOfActualSelectedContextView];
        title = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:value];
    } else {
        id modelObj = [self findModelObjectOfActualSelectedContextView];
        CategoryType categoryType = [self isTheIncomesOptionSelectedInReportMenu] ? IncomeCategory : ExpenseCategory;
        NSArray *categories = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:categoryType];
        IAECategory *category = categories[itemIndex];
        NSDecimalNumber *value = [modelObj sumAllAmountOfCategories:@[category]];
        title = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:value];
    }
    
    return title;
}

- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView subtitleOfItemWithIndex:(NSUInteger)itemIndex
{
    NSString *subtitle = nil;
    
    if ([self isTheBalancesOptionSelectedInReportMenu]) {
        subtitle = itemIndex == 0 ? NSLocalizedString(kLtextIncomeCategoryTypeName, @"") : NSLocalizedString(kLtextExpenseCategoryTypeName, @"");
    } else {
        NSArray *categories = [self isTheIncomesOptionSelectedInReportMenu] ? [self findIncomesCategoriesOfActualSelectedContextView] :
        [self findExpensesCategoriesOfActualSelectedContextView];
        IAECategory *category = categories[itemIndex];
        subtitle = category.tag;
    }
    
    return subtitle;
}

#pragma mark - IAEReportAreaViewDelegate



@end
