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
#import "IAESelectorContextView.h"
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
#import "IAEDragPanelCalculatorView.h"

@interface IAEEasyIncomesAndExpensesViewController ()
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIView *containerViewForDynamicFX;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *yearsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesButton;

@property (weak, nonatomic) IBOutlet IAESelectorContextView *selectorContextView;
@property (weak, nonatomic) IBOutlet UIView *editAndReportModeContentContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;
@property (nonatomic, strong) IAEYearSelectorViewController *yearSelectorViewController;
@property (nonatomic, strong) IAECategorySelectorViewController *categoriesSelectorViewController;
@property (nonatomic, strong) IAEAboutAndOptionsViewController *aboutAndOptionsViewController;
@property (nonatomic, strong) IAEReportAreaView *reportAreaView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *contextMenuView;
@property (nonatomic, strong) IAETextRawSelectorMenuView *reportMenuView;
@property (nonatomic, strong) IAECalculatorViewController *calculatorViewController;
@property (nonatomic, strong) IAEHelperReportAreaViewDataSource *helperReportAreaViewDataSource;
@property (nonatomic, strong) IAEHelperContextTextRawMenuDataSource *helperContextTextRawMenuDataSource;
@property (nonatomic, strong) IAEHelperReportTextRawMenuDataSource *helperReportTextRawMenuDataSource;
@property (nonatomic, strong) IAEHelperCalculatorDataSource *helperCalculatorDataSource;
@property (nonatomic, strong) IAEHelperConceptsCollectionViewDataSource *helperConceptsCollectionViewDataSource;
@property (nonatomic, strong) UIView *withoutConceptsWarningInMonthEditModeView;
@property (nonatomic, strong) UIView *withoutConceptsWarningInMonthReportModeView;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UITapGestureRecognizer *tapConceptsRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeConceptsGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panCalculatorGestureRecognizer;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@property (nonatomic, weak) IAEEditModeConceptCollectionViewCell *conceptCellToRemove;
@property (nonatomic) BOOL initialPositioning;
@property (nonatomic, weak) IAECategory *categoryRenaming;
@property (nonatomic, weak) IAEConcept *conceptChangingDay;
@property (nonatomic) BOOL reloadAllPendingFromYearSelectorIfReturnWithSameYearDate;
@property (nonatomic) NSInteger lastContextIndexMenuPressed;
@property (nonatomic, strong) UIAttachmentBehavior *attachBehaviorForContainerFX;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation IAEEasyIncomesAndExpensesViewController

#pragma mark - Constants

static const NSUInteger kNumberOfMonths = 12;

static NSString * const kLTextYearsBarButtonTitle = @"LTEXT_BARBUTTON_YEARS_TITLE";
static NSString * const kLTextSettingsBarButtonTitle = @"LTEXT_BARBUTTON_SETTINGS_TITLE";
static NSString * const kLTextCategoriesBarButtonTitle = @"LTEXT_BARBUTTON_CATEGORIES_TITLE";

static const CGFloat kEditAndReportModeContentContainerRadius = 15;
static const CGFloat kColorWithWhiteForEditAndReportModeContentContainerBackground = 0.97;

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

static NSString * const kLTextModeSegmentedControlEditMode = @"LTEXT_MODESEGMENTEDCONTROL_EDITMODE";
static NSString * const kLTextModeSegmentedControlReportmode = @"LTEXT_MODESEGMENTEDCONTROL_REPORTMODE";

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
static const NSInteger kTypeStrokeAnimationForConcepts = STROKEANIMATABLE_TYPE_THIN;
static const CGFloat kDelayToExecuteRemoveConceptCell = 0.2;

static const CGFloat KDurationOfAnimationUpdateForEntryInstantIndex = 0.15;

static const CGFloat kDurationOfEditConceptCollectionViewTransition = 0.5;

static NSString * const kXibWithoutConceptsWarningInEditModeViewName = @"IAEWithoutConceptsTextWarning";
static NSString * const kXibWithoutConceptsWarningInReportModeViewName = @"IAEWithoutConceptsTextWarningReportMode";
static const CGFloat kDurationOfWithoutConceptsWarningVieTransition = 0.5;

static const CGFloat kDurationOfFrameUpdateWhenShowOrHideCalculator = 0.25;

static const NSInteger kInvalidOptionIndex = -1;

static const CGFloat kFrecuencyForContainerFXAttachBehavior = 1.5;
static const CGFloat kDampingForContainerFXAttachBehavior = 2;

static const CGFloat kDurationModeFadeOut = 0.35;
static const CGFloat kDurationModeFadeIn = 0.75;

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

- (UIView *)withoutConceptsWarningInMonthEditModeView
{
    if (!_withoutConceptsWarningInMonthEditModeView) {
        _withoutConceptsWarningInMonthEditModeView = [UIView viewFromXib:kXibWithoutConceptsWarningInEditModeViewName withOwner:self];
        [self configureInitialValuesOfWithoutConceptWarningView:_withoutConceptsWarningInMonthEditModeView];
    }
    
    return _withoutConceptsWarningInMonthEditModeView;
}

- (UIView *)withoutConceptsWarningInMonthReportModeView
{
    if (!_withoutConceptsWarningInMonthReportModeView) {
        _withoutConceptsWarningInMonthReportModeView = [UIView viewFromXib:kXibWithoutConceptsWarningInReportModeViewName withOwner:self];
        [self configureInitialValuesOfWithoutConceptWarningView:_withoutConceptsWarningInMonthReportModeView];
    }
    
    return _withoutConceptsWarningInMonthReportModeView;
}

- (void)configureInitialValuesOfWithoutConceptWarningView:(UIView *)withoutConceptWarningView
{
    [self.editAndReportModeContentContainerView addSubview:withoutConceptWarningView];
    withoutConceptWarningView.center = CGPointMake(self.editAndReportModeContentContainerView.bounds.size.width / 2,
                                                   self.editAndReportModeContentContainerView.bounds.size.height / 2);
    withoutConceptWarningView.alpha = 0;
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.calculatorViewController removePanGestureRecognizer];
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
        [self initPanCalculatorGestureRecognizer];
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
    _initialPositioning = YES;
    _lastContextIndexMenuPressed = -1;
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

- (void)initPanCalculatorGestureRecognizer
{
    _panCalculatorGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnCalculatorView:)];
}

- (void)initAsObserverOfNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
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
    [self configureBarButtonsTitle];
    [self configureSelectorContextView];
    [self configureEditAndReportModeContentContainerView];
    [self configureCalculatorViewController];
    [self configureConceptsViews];
    [self configureReportAreaView];
    [self configureReportMenuView];
}

- (void)configureBarButtonsTitle
{
    [self.yearsButton setTitle:NSLocalizedString(kLTextYearsBarButtonTitle, @"")];
    [self.categoriesButton setTitle:NSLocalizedString(kLTextCategoriesBarButtonTitle, @"")];
}

- (void)configureSelectorContextView
{
    self.selectorContextView.delegate = self;
}

- (void)configureCalculatorViewController
{
    [self.calculatorViewController addPanGestureRecognizer:self.panCalculatorGestureRecognizer];
    self.calculatorViewController.delegate = self;
    self.calculatorViewController.dataSource = self.helperCalculatorDataSource;
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
    self.conceptsCollectionView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.conceptsCollectionView.bounces = YES;
    
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
    
    [self vinculeSelectorContextViewContent];
    [self vinculeContextMenuView];
    [self vinculeCalculatorViewControllerView];
    [self vinculeReportAreaView];
    [self vinculeReportMenuView];
    [self createAndVinculeAttachBehavior];
    
    [self gotoToTodayMonthByInitialPositioning];

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
    [self.containerViewForDynamicFX addSubview:_contextMenuView];
    self.contextMenuView.delegate = self;
    self.contextMenuView.dataSource = self.helperContextTextRawMenuDataSource;
    self.contextMenuView.center = CGPointMake(self.selectorContextView.center.x,
                                              self.selectorContextView.center.y + self.selectorContextView.bounds.size.height / 2 + self.contextMenuView.bounds.size.height / 2);
}

- (void)vinculeCalculatorViewControllerView
{
    self.calculatorViewController.view.frame = CGRectMake(0,
                                                          0,
                                                          self.calculatorViewController.view.bounds.size.width,
                                                          self.calculatorViewController.view.bounds.size.height);
    
    CGFloat centerY = self.view.frame.size.height + self.calculatorViewController.view.bounds.size.height / 2 - self.calculatorViewController.sizeHeightOfDragPanel;
    self.calculatorViewController.view.center = CGPointMake(self.view.center.x, centerY);
    
    [self.view addSubview:self.calculatorViewController.view];
    [self.calculatorViewController calculeDragLimits];
}

- (void)vinculeReportAreaView
{
    self.reportAreaView.frame = CGRectMake(0,
                                           0,
                                           self.editAndReportModeContentContainerView.frame.size.width,
                                           self.editAndReportModeContentContainerView.frame.size.height);
    [self.editAndReportModeContentContainerView addSubview:self.reportAreaView];
    self.reportAreaView.hidden = YES;
}

- (void)vinculeReportMenuView
{
    [self.view addSubview:self.reportMenuView];
    self.reportMenuView.dataSource = self.helperReportTextRawMenuDataSource;
    self.reportMenuView.delegate = self;
    CGFloat centerY = self.view.frame.size.height - self.reportMenuView.bounds.size.height / 1.5;
    self.reportMenuView.center = CGPointMake(self.view.center.x, centerY);
    self.reportMenuView.hidden = YES;
}

- (void)createAndVinculeAttachBehavior
{
    self.attachBehaviorForContainerFX = [[UIAttachmentBehavior alloc] initWithItem:self.containerViewForDynamicFX
                                                                  attachedToAnchor:self.calculatorViewController.view.center];
    
    
    self.attachBehaviorForContainerFX.frequency = kFrecuencyForContainerFXAttachBehavior;
    self.attachBehaviorForContainerFX.damping = kDampingForContainerFXAttachBehavior;
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [self.dynamicAnimator addBehavior:self.attachBehaviorForContainerFX];
}

- (void)gotoToTodayMonthByInitialPositioning
{
    self.initialPositioning = YES;
    
    [self goToTodayMonth];
    
    self.initialPositioning = NO;
}

- (void)goToTodayMonth
{
    NSUInteger globalContextViewIndex = [self findTodayMonthContextViewGlobalIndexInSelectorContextView];
    [self gotoToContextViewWithIndex:globalContextViewIndex];
}

- (void)gotoToContextViewWithIndex:(NSUInteger)contextIndex
{
    [self.selectorContextView changeToContextViewOfIndex:contextIndex withAnimation:!self.initialPositioning];
}

#pragma mark - ControlEvents

- (IBAction)categoriesButtonPressed:(id)sender
{
    [self openModalForPresentCategorySelectorViewController];
}

- (void)openModalForPresentCategorySelectorViewController
{
    NSUInteger extraActions = CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTIONWITHOUTDECORATOR |
                              CATEGORYSELECTOR_EXTRAACTION_ADD |
                              CATEGORYSELECTOR_EXTRAACTION_DONE |
                              CATEGORYSELECTOR_EXTRAACTION_DELETE;
    self.categoriesSelectorViewController = [[IAECategorySelectorViewController alloc] initWithExtraActions:extraActions
                                                                                                                   withSelectedCategory:nil];
    self.categoriesSelectorViewController.showNumberOfConcepts = YES;
    self.categoriesSelectorViewController.delegate = self;
    self.categoriesSelectorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.categoriesSelectorViewController animated:YES completion:nil];
}

- (IBAction)yearsButtonPressed:(id)sender
{
    [self openModalForPresentYearSelectorViewController];
}

- (void)openModalForPresentYearSelectorViewController
{
    self.yearSelectorViewController = [[IAEYearSelectorViewController alloc] initWithNibName:nil bundle:nil];
    self.yearSelectorViewController.delegate = self;
    self.yearSelectorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.yearSelectorViewController animated:YES completion:nil];
}

- (IBAction)settingsOptionPressed:(id)sender
{
    self.aboutAndOptionsViewController = [[IAEAboutAndOptionsViewController alloc] initWithNibName:nil bundle:nil];
    self.aboutAndOptionsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.aboutAndOptionsViewController animated:YES completion:nil];
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
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationModeFadeOut animations:^{
        self.editAndReportModeContentContainerView.alpha = 0.0;
        self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y + self.reportMenuView.bounds.size.height);
    } completion:^(BOOL finished) {
        self.withoutConceptsWarningInMonthReportModeView.alpha = 0;
        self.reportAreaView.dataSource = nil;
        self.reportAreaView.reportAreaViewDelegate = self;
        self.reportAreaView.hidden = YES;
        self.reportMenuView.hidden = YES;
        self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y - self.reportMenuView.bounds.size.height);
        if ([self findNumberOfConceptsOfActualSelectedContext:0] > 0) {
            [self.conceptsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
        self.conceptsCollectionView.hidden = NO;
        [self.conceptsCollectionView reloadData];
        self.calculatorViewController.view.hidden = NO;
        self.editAndReportModeContentContainerView.backgroundColor = [UIColor colorWithWhite:kColorWithWhiteForEditAndReportModeContentContainerBackground
                                                                                alpha:1.0];
        [UIView animateWithDuration:kDurationModeFadeIn animations:^{
            self.withoutConceptsWarningInMonthEditModeView.alpha = [self existConceptsInActualSelectedContext] > 0 ? 0.0 : 1.0;
            self.editAndReportModeContentContainerView.alpha = 1.0;
            self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x, self.calculatorViewController.view.center.y - self.calculatorViewController.dragPanel.bounds.size.height);
        } completion:^(BOOL finished) {
            [self updateCalculatorViewHideHalfState];
        }];
    }];
}


- (void)updateAfterChangeToReportMode
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationModeFadeOut animations:^{
        self.editAndReportModeContentContainerView.alpha = 0.0;
        self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x, self.calculatorViewController.view.center.y + self.calculatorViewController.dragPanel.bounds.size.height);
    } completion:^(BOOL finished) {
        self.withoutConceptsWarningInMonthEditModeView.alpha = 0;
        self.reportAreaView.dataSource = self.helperReportAreaViewDataSource;
        self.reportAreaView.reportAreaViewDelegate = self;
        self.reportMenuView.currentOptionIndexSelected = 0;
        self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y + self.reportMenuView.bounds.size.height);
        self.reportAreaView.hidden = NO;
        self.reportMenuView.hidden = NO;
        self.conceptsCollectionView.hidden = YES;
        self.calculatorViewController.view.hidden = YES;
        self.editAndReportModeContentContainerView.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:kDurationModeFadeIn animations:^{
            self.withoutConceptsWarningInMonthReportModeView.alpha = [self existConceptsInActualSelectedContext] > 0 ? 0.0 : 1.0;
            self.editAndReportModeContentContainerView.alpha = 1.0;
            self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y - self.reportMenuView.bounds.size.height);
        } completion:^(BOOL finished) {
            self.reportMenuView.optionsEnabled = [self existConceptsInActualSelectedContext];
            self.reportMenuView.currentOptionIndexSelected = kReportMenuIndexOfBalancesOption;
        }];
    }];
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

- (NSDecimalNumber *)findMaxValueForActualSelectedContextForCategoryType:(CategoryType)categoryType
{
    NSAssert(categoryType != InvalidCategory, @"");

    id modelObject = [self findModelObjectOfActualSelectedContextView];
    NSArray *allCategories = categoryType == IncomeCategory ? [self findIncomesCategoriesOfActualSelectedContextView] : [self findExpensesCategoriesOfActualSelectedContextView];
    NSDecimalNumber *maxValue = [self findForModelObject:modelObject maxBalanceValueOfCategories:allCategories];
    
    return maxValue;
}

- (NSDecimalNumber *)findMaxValueOfAllCategoriesForActualSelectedContext
{
    id modelObject = [self findModelObjectOfActualSelectedContextView];
    NSArray *allCategories = [self findAllCategoriesForActualSelectedContext];
    NSDecimalNumber *maxValue = [self findForModelObject:modelObject maxBalanceValueOfCategories:allCategories];
    
    return maxValue;
}

- (NSDecimalNumber *)findForModelObject:(id)modelObject maxBalanceValueOfCategories:(NSArray *)categories
{
    NSDecimalNumber *maxValue = [NSDecimalNumber zero];

    for (IAECategory *category in categories) {
        NSDecimalNumber *categoryValue = [modelObject balanceOfAllConceptsOfCategory:category];
        if ([categoryValue compare:maxValue] == NSOrderedDescending) {
            maxValue = categoryValue;
        }
    }
    
    return maxValue;
}

- (NSArray *)findAllCategoriesForActualSelectedContext
{
    NSArray *incomeCategories = [self findIncomesCategoriesOfActualSelectedContextView];
    NSArray *expenseCategories = [self findExpensesCategoriesOfActualSelectedContextView];
    NSSet *allCategories = [NSSet setWithArray:incomeCategories];
    allCategories = [allCategories setByAddingObjectsFromArray:expenseCategories];
    
    return [allCategories sortedArrayUsingDescriptors:[NSSortDescriptor sortDescriptorWithKey:@"categoryType" ascending:YES]];
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
    // ToDo: Este metodo está fatalmente nombrado por culpa de ese parametro que se usa solo si hay año
    NSUInteger numberOfConcepts = 0;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *month = [self findActualSelectedMonth];
        numberOfConcepts = month.concepts.count;
    } else {
        NSArray *months = [self findAllOrdererMonthsWithConceptsOfOpenYear];
        if (months.count > 0) {
            IAEMonth *month = months[section];
            numberOfConcepts = month.concepts.count;
        }
    }
    
    return numberOfConcepts;
}

- (BOOL)existConceptsInActualSelectedContext
{
    NSUInteger numberOfConcepts = [self findNumberOfConceptsOfActualSelectedContext:0];
    
    return numberOfConcepts > 0;
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

- (IAECategory *)findCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAECategory *categoryOfConcept = concept.category;
    
    return categoryOfConcept;
}

- (CategoryType)findCategoryTypeOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAECategory *categoryOfConcept = concept.category;
    
    return categoryOfConcept.categoryType;
}

- (NSUInteger)findTodayMonthContextViewGlobalIndexInSelectorContextView
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
        NSAssert(indexPath, @"");
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
    IAEContextView *contextView = [self.selectorContextView findContextViewAtIndex:globalPosition];
    
    return contextView;
}

- (BOOL)categorySelectorViewControllerWasLaunchedFromCategoryButton
{
    // Nota: Solo tendra sentido si realmente se ha lanzado
    return self.popover == nil;
}

- (BOOL)categorySelectorViewControllerWasLaunchedFromConcept
{
    return self.popover != nil && [self.calculatorViewController isClosed];
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
    if (![self.calculatorViewController isOpen]) {
        [self updateSelectedMonthBalanceWithAnimation:animation];
        [self updateOpenYearBalance];
    }
}

- (void)updateSelectedMonthBalanceWithAnimation:(BOOL)animation
{
    IAEContextView *contextView = [self findActualSelectedMonthContextView];
    if (animation) {
        [contextView reloadDataWithAnimationFromUsingZeroValue:NO];
    } else {
        [contextView reloadDataWithoutAnimation];
    }
}

- (void)updateOpenYearBalance
{
    IAEContextView *contextView = [self findOpenYearContextView];
    [contextView reloadDataWithoutAnimation];
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

- (void)vinculeSelectorContextViewContent
{
    const NSUInteger numberOfContextView = 1 + 12; // 1 año y 12 meses
    const NSUInteger yearIndex = 0;
    for (NSUInteger index = 0; index < numberOfContextView; ++index) {
        IAEContextViewType contextViewType = index == yearIndex ? CONTEXT_VIEW_YEAR : CONTEXT_VIEW_MONTH;
        NSUInteger valueIndex = index == yearIndex ? [self findOpenYear].yearDate : January + index - 1;
        [self addToSelectorContextViewWithGlobalPosition:index contextType:contextViewType andValueIndex:valueIndex];
    }
}

- (void)addToSelectorContextViewWithGlobalPosition:(NSUInteger)globalPosition
                                            contextType:(IAEContextViewType)contextType
                                          andValueIndex:(NSUInteger)contextValueIndex
{
    // ToDo: La definicion de las dimensiones se podria hacer en el propio selector
    CGRect frame = CGRectMake(0, 0, self.selectorContextView.bounds.size.width, self.selectorContextView.bounds.size.height);
    IAEContextView *contextView = [[IAEContextView alloc] initWithFrame:frame type:contextType andValueIndex:contextValueIndex];
    contextView.dataSource = self;
    [contextView reloadDataWithoutAnimation];
    
    [self.selectorContextView addContextView:contextView withIndex:globalPosition];
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

#pragma mark - IAEReportAreaViewDelegate

- (void)reloadDataWithAnimationWasDoneInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:!self.initialPositioning];
    [self disableOrEnableReportMenuIfAppropiate];
}

#pragma mark - IAESelectorContextView Delegate

- (BOOL)isReportScrollView:(UIScrollView *)scrollView
{
    BOOL reportScrollView = scrollView == (UIScrollView *)self.reportAreaView;
    
    return reportScrollView;
}

- (void)selectorContextView:(IAESelectorContextView *)selectorContextView didChangeToContextViewAtIndex:(NSUInteger)index
{
    [self updateContentInformationBasedInCurrentContext];
}

- (void)updateContentInformationBasedInCurrentContext
{
    if (self.lastContextIndexMenuPressed != kInvalidOptionIndex) {
        [self.selectorContextView changeToContextViewOfIndex:self.lastContextIndexMenuPressed withAnimation:YES];
        self.lastContextIndexMenuPressed = kInvalidOptionIndex;
    } else {
        [self updateCurrentOptionIndexSelectedOfContextMenu];
        if ([self isEditModeActive]) {
            [self updateConceptsCollectionViewWithAnimation:!self.initialPositioning];
            [self updateCalculatorViewHideHalfState];
        } else if ([self isReportModeActive]) {
            // Si hay aviso de que venimos de un contexto sin conceptos, primero comprobamos si hay que quitarlo y luego recargamos.
            // Si NO venimos del caso anterior, primero recargamos y luego, en el delegado, comprobamos si estamos en un contexto sin conceptos
            // NOTA: En el primer caso también llamamos al delegado y volvemos a ejecutar showWithout... pero no pasara nada ya que el estado se habra
            // establecido en la primera llamada.
            if ([self isAnyWithoutConceptsWarningViewVisible]) {
                [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES andExecuteAfterAnimationTheLogicBlock:^{
                    [self.reportAreaView reloadDataWithAnimation:YES];
                }];
            } else {
                [self.reportAreaView reloadDataWithAnimation:YES];
            }
        }
    }
}

- (BOOL)isAnyWithoutConceptsWarningViewVisible
{
    const BOOL isAny = self.withoutConceptsWarningInMonthEditModeView.alpha == 1.0 || self.withoutConceptsWarningInMonthReportModeView.alpha == 1.0;
    
    return isAny;
}

- (void)updateConceptsCollectionViewWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView animateWithDuration:kDurationOfEditConceptCollectionViewTransition animations:^{
            self.conceptsCollectionView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation];
            [self updateContentOfConceptsCollectionView];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:kDurationOfEditConceptCollectionViewTransition animations:^{
                self.conceptsCollectionView.alpha = 1.0;
            }];
        }];
    } else {
        [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation];
        [self updateContentOfConceptsCollectionView];
    }
}

- (void)disableOrEnableReportMenuIfAppropiate
{
    self.reportMenuView.optionsEnabled = [self existConceptsInActualSelectedContext];
}

- (void)showWithoutConceptsWarningViewIfAppropriateWithAnimation:(BOOL)animation
{
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation andExecuteAfterAnimationTheLogicBlock:nil];
}

- (void)showWithoutConceptsWarningViewIfAppropriateWithAnimation:(BOOL)animation
                           andExecuteAfterAnimationTheLogicBlock:(void(^)(void))logicBlock
{
    const BOOL show = [self existConceptsInActualSelectedContext] == 0;
    CGFloat alpha = show ? 1.0 : 0.0;
    
    void(^ alphaChanges)(void) = ^(void) {
        if ([self isEditModeActive]) {
            self.withoutConceptsWarningInMonthEditModeView.alpha = alpha;
            self.withoutConceptsWarningInMonthReportModeView.alpha = 0;
        } else if ([self isReportModeActive]) {
            self.withoutConceptsWarningInMonthReportModeView.alpha = alpha;
            self.withoutConceptsWarningInMonthEditModeView.alpha = 0;
        }
    };
    
    void(^ logicBlockExecuteChecker)(void) = ^(void) {
        if (logicBlock) {
            logicBlock();
        }
    };
    
    if (animation) {
        [UIView animateWithDuration:animation ? kDurationOfWithoutConceptsWarningVieTransition : 0 animations:^{
            alphaChanges();
        } completion:^(BOOL finished) {
            logicBlockExecuteChecker();
        }];
    } else {
        alphaChanges();
        logicBlockExecuteChecker();
    }
}

- (void)updateCurrentOptionIndexSelectedOfContextMenu
{
    self.contextMenuView.currentOptionIndexSelected = [self.selectorContextView findActualContextViewIndex];
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
}

#pragma mark - IAEContextViewDataSource

- (NSString *)nameForContextView:(IAEContextView *)contextView
{
    NSString *name = nil;
    
    IAEYear *year = [self findOpenYear];
    if (contextView.contextType == CONTEXT_VIEW_MONTH) {
        IAEMonth *month = [year.ordererMonths objectAtIndex:contextView.valueIndex - 1];
        name = [month monthAsString];
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
        [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES];
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

#pragma mark - UIPanGestureRecognizer

- (void)panOnCalculatorView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.calculatorViewController beginDragTranslation];
    }
    
    CGPoint translation = [panGestureRecognizer translationInView:self.calculatorViewController.dragPanel];
    [self.calculatorViewController doDragTranslation:translation.y];
    self.attachBehaviorForContainerFX.anchorPoint = self.calculatorViewController.view.center;
    [panGestureRecognizer setTranslation:CGPointZero inView:self.calculatorViewController.dragPanel];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.calculatorViewController endDragTranslation];
    }
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

    [self createAndPresentPopoverForConceptCellView:[cell findAmountLabel] withViewController:viewController];
}

- (void)openPopoverForEditCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAECategory *categoryOfCell = [self findCategoryOfConceptCell:cell];
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc]
                                                         initWithExtraActions:CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION
                                                         withSelectedCategory:categoryOfCell];
    viewController.showNumberOfConcepts = NO;
    viewController.delegate = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];
    
    [self createAndPresentPopoverForConceptCellView:[cell findCategoryLabel] withViewController:viewController];
}

- (void)createAndPresentPopoverForConceptCellView:(UIView *)view withViewController:(UIViewController *)viewController
{
    CGRect translateViewFrameToGlobalCoordination = [view.superview convertRect:view.frame toView:view.superview];
    CGRect presentPopoverFrame = CGRectMake(translateViewFrameToGlobalCoordination.origin.x,
                                            translateViewFrameToGlobalCoordination.origin.y + 10.0,
                                            translateViewFrameToGlobalCoordination.size.width,
                                            translateViewFrameToGlobalCoordination.size.height - 10.0);
    
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
    const NSUInteger numberOfConceptsBeforeRemove = month.concepts.count;
    const NSUInteger numberOfConceptsAfterRemove = numberOfConceptsBeforeRemove - 1;
    NSIndexPath *indexPathOfCell = [self.conceptsCollectionView indexPathForCell:cell];
    const BOOL isLastCell = indexPathOfCell.row == numberOfConceptsBeforeRemove - 1;
    
    [month removeConcept:concept];
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView performBatchUpdates:^{
        [self.conceptsCollectionView deleteItemsAtIndexPaths:@[[self.conceptsCollectionView indexPathForCell:cell]]];
        if (isLastCell && numberOfConceptsAfterRemove > 0) {
            NSIndexPath *indexPathOfNewLastCell = [NSIndexPath indexPathForRow:indexPathOfCell.row - 1
                                                                  inSection:indexPathOfCell.section];
            [self.conceptsCollectionView reloadItemsAtIndexPaths:@[indexPathOfNewLastCell]];
        }
    } completion:^(BOOL finished) {
        [self updateBalancesWithAnimation:YES];
    }];
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
    if ([self categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self launchCategoryEditorViewControllerModalFromCategorySelectorViewController:categorySelectorViewController ToRenameCategory:category];
    } else if ([self categorySelectorViewControllerWasLaunchedFromConcept]) {
        [self dismissPopoverAndChangeCategoryOfConceptAtIndexPath:categorySelectorViewController.conceptCellIndexPath toCategory:category];
    } else {
        NSAssert(0, @"Nunca se deberia de llegar a este punto");
    }
}

- (void)dismissPopoverAndChangeCategoryOfConceptAtIndexPath:(NSIndexPath *)indexPath toCategory:(IAECategory *)category
{
    [self dismisPopover];
    [self changeCategoryOfConceptAtIndexPath:indexPath toCategory:category];
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

- (void)launchCategoryEditorViewControllerModalFromCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
                                                                 ToRenameCategory:(IAECategory *)category
{
    if (![[IAECategoryStore sharedCategoryStore] isGeneralCategory:category]) {
        self.categoryRenaming = category;
        
        IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToRenameCategory:category];
        categoryEditorViewController.delegate = self;
        categoryEditorViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [categorySelectorViewController presentViewController:categoryEditorViewController animated:YES completion:nil];
    }
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
               didSelectRemoveCategory:(IAECategory *)category
{
    NSString *tagOfCategory = [category.tag copy];
    [[IAECategoryStore sharedCategoryStore] removeCategoryByTag:tagOfCategory];
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView reloadData];
    NSAssert([self categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [categorySelectorViewController reloadAfterRemoveCellWithCategoryTag:tagOfCategory];
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
    self.yearSelectorViewController = nil;
}

- (void)reloadAllWithAnimation:(BOOL)animation
{
    [self.contextMenuView reloadOptionsStringNames];
    [self reloadBalancesOfContextViewsWithAnimation:animation];
    [self reloadConceptsOfActualSelectedContextView];
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation];
}

- (void)reloadAllAndGoToTodayMonthWithAnimation:(BOOL)animation
{
    [self reloadAllWithAnimation:animation];
    [self goToTodayMonth];
}

- (void)reloadBalancesOfContextViewsWithAnimation:(BOOL)animation
{
    [self.selectorContextView enumerateContextViewsUsingBlock:^(NSUInteger index, IAEContextView *contextView) {
        if (animation) {
            [contextView reloadDataWithAnimationFromUsingZeroValue:NO];
        } else {
            [contextView reloadDataWithoutAnimation];
        }
    }];
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

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self closeModalsAfterEnterBackground];
}

- (void)closeModalsAfterEnterBackground
{
    [self.yearSelectorViewController closeButtonPressed:nil];
    /*[self.categoriesSelectorViewController doneButtonPressed:nil];
    [self.aboutAndOptionsViewController doneButtonPressed:nil];
    if (self.contextMenuView.currentOptionIndexSelected > 0 && [self isEditModeActive]) {
        [self.calculatorViewController hide];
    }
     */
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

- (void)setNavigationButtonsEnabled:(BOOL)enabled
{
    self.yearsButton.enabled = enabled;
    self.categoriesButton.enabled = enabled;
}

- (void)showButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [self setNavigationButtonsEnabled:NO];
    
    self.attachBehaviorForContainerFX.anchorPoint = self.calculatorViewController.view.center;
}

- (void)hideButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [self updateBalancesWithAnimation:YES];

    [self setNavigationButtonsEnabled:YES];
    
    self.attachBehaviorForContainerFX.anchorPoint = self.calculatorViewController.view.center;
}

- (void)updateFramePositionBeforeShowCalculatorForView:(UIView *)view
{
    [self updateFramePositionChangingVisibilityOfCalculatorForView:view withYOffset:-self.calculatorViewController.sizeHeightOffsetWhenShowed];
}

- (void)updateFramePositionAfterShowCalculatorForView:(UIView *)view
{
    [self updateFramePositionChangingVisibilityOfCalculatorForView:view withYOffset:self.calculatorViewController.sizeHeightOffsetWhenShowed];
}

- (void)updateFramePositionChangingVisibilityOfCalculatorForView:(UIView *)view withYOffset:(CGFloat)offset
{
    view.frame = CGRectMake(view.frame.origin.x,
                            view.frame.origin.y + offset,
                            view.frame.size.width,
                            view.frame.size.height);
}

#pragma mark - IAECalculatorViewControllerDelegate

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept
{
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES andExecuteAfterAnimationTheLogicBlock:^{
        [self reloadConceptsCollectionViewAfterCreateNewConcept:concept];
        [self updateBalancesWithAnimation:NO];
    }];
}

- (void)reloadConceptsCollectionViewAfterCreateNewConcept:(IAEConcept *)concept
{
    if ([self isDayModeActiveForConcepts]) {
        [self reloadConceptsCollectionViewWithDayModeAfterCreateNewConcept:concept];
    } else {
        [self reloadConceptsCollectionViewWithoutDayModeAfterCreateNewConcept];
    }
}

- (void)reloadConceptsCollectionViewWithDayModeAfterCreateNewConcept:(IAEConcept *)concept
{
    NSArray *concepts = [self allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:nil];
    NSUInteger indexOfConcept = [concepts indexOfObject:concept];
    NSIndexPath *indexPathOfInsertion = [NSIndexPath indexPathForRow:indexOfConcept inSection:0];
    
    [self.conceptsCollectionView performBatchUpdates:^{
        [self.conceptsCollectionView insertItemsAtIndexPaths:@[indexPathOfInsertion]];
    } completion:^(BOOL finished) {
        // Aquí debería de haber algún tipo de efecto especial para indicar la celda añadida
        [self.conceptsCollectionView scrollToItemAtIndexPath:indexPathOfInsertion atScrollPosition:UIScrollViewIndicatorStyleDefault animated:YES];
    }];
}

- (void)reloadConceptsCollectionViewWithoutDayModeAfterCreateNewConcept
{
    NSUInteger numberOfConceptsForActualContext = [self findNumberOfConceptsOfActualSelectedContext:0];
    NSIndexPath *indexPathOfInsertion = [NSIndexPath indexPathForRow:numberOfConceptsForActualContext - 1 inSection:0];
    
    [self.conceptsCollectionView performBatchUpdates:^{
        [self.conceptsCollectionView insertItemsAtIndexPaths:@[indexPathOfInsertion]];
        [self.conceptsCollectionView reloadItemsAtIndexPaths:self.conceptsCollectionView.indexPathsForVisibleItems];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - IAETextRawSelectorMenuViewDelegate

- (void)optionIndex:(NSUInteger)optionIndex wasSelectedInTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        if ([self isChangeOfContextRunning]) {
            self.lastContextIndexMenuPressed = optionIndex;
        } else {
            [self gotoToContextViewWithIndex:optionIndex];
        }
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenu]) {
        [self.reportAreaView reloadDataWithAnimation:YES];
    }
}

- (BOOL)isChangeOfContextRunning
{
    return [self.selectorContextView isAnimationInProgress];
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
