//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "IAEEasyIncomesAndExpensesViewController.h"
#import "IAEEasyIncomesAndExpensesViewControllerDefs.h"
#import "IAEEasyIncomesAndExpensesViewControllerDelegate.h"
#import "IAEBook.h"
//#import "IAEYear.h"
#import "IAEOpenYear.h"
#import "IAEMonth.h"
#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAESelectorContextView.h"
#import "IAEContextView.h"
#import "IAEEditModeConceptCollectionViewHeader.h"
#import "IAEAdjustConceptAmountViewController.h"
#import "IAECategorySelectorViewController.h"
#import "IAECategoryEditorViewController.h"
#import "IAEYearSelectorViewController.h"
#import "IAESettingsViewController.h"
#import "IAEDayCalendarSelectorViewController.h"
#import "IAECalculatorViewController.h"
#import "IAETextRawSelectorMenuView.h"
#import "IAEReportAreaView.h"
#import "IAEHelperReportAreaViewDataSource.h"
#import "IAEHelperContextTextRawMenuDataSource.h"
#import "IAEHelperReportTextRawMenuDataSource.h"
#import "IAEHelperCalculatorDataSource.h"
#import "IAEHelperConceptsCollectionViewDataSource.h"
#import "IAECategoryStore.h"
#import "UIView+LoadFromXib.h"
#import "NSDecimalNumber+AbsoluteValue.h"
#import "IAEStrokeAnimatableLineView.h"
#import "IAEDragPanelCalculatorView.h"
#import "IAEFixRemoveCategoryActionLostInUnloadedYears.h"
#import "IAEFavoriteConceptsStock.h"
#import "IAEFavoriteConceptsViewController.h"
#import "IAEMonthSelectorViewController.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEExporter.h"
#import "IAEContextMenuActionSheetViewController.h"
#import "IAEInAppPurchaseStoreViewController.h"
#import "IAEInAppPurchasesStore.h"
#import "IAEInternet.h"
#import "IAEMainNavigationTitle.h"
#import "IAEEasyIncomesAndExpensesQuery.h"

@interface IAEEasyIncomesAndExpensesViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerViewForDynamicFX;
@property (strong, nonatomic) UIBarButtonItem *yearsButton;
@property (strong, nonatomic) UIBarButtonItem *categoriesButton;
@property (strong, nonatomic) UIBarButtonItem *favoritesButton;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet IAESelectorContextView *selectorContextView;
@property (weak, nonatomic) IBOutlet UIView *editAndReportModeContentContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *conceptsCollectionView;
@property (nonatomic, strong) UIImageView *editAndReportModeContentContainerViewBackground;
@property (nonatomic, strong) IAEYearSelectorViewController *yearSelectorViewController;
@property (nonatomic, strong) IAECategorySelectorViewController *categoriesSelectorViewController;
@property (nonatomic, strong) IAESettingsViewController *aboutAndOptions2ViewController;
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
@property (nonatomic, strong) UITapGestureRecognizer *tapEditAndReportModeContainerViewRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightConceptsGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftConceptsGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panCalculatorGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchConceptsGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressureConceptsGestureRecognizer;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@property (nonatomic, weak) IAEEditModeConceptCollectionViewCell *conceptCellToRemove;
@property (nonatomic) BOOL initialPositioning;
@property (nonatomic, weak) IAECategory *categoryRenaming;
@property (nonatomic) BOOL reloadAllPendingFromYearSelectorIfReturnWithSameYearDate;
@property (nonatomic) NSInteger lastContextIndexMenuPressed;
@property (nonatomic, strong) UIAttachmentBehavior *attachBehaviorForContainerFX;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSIndexPath *pendingScrollToEditModeConceptCellIndexPath;
@property (nonatomic, strong) IAEMonthSelectorViewController *monthSelectorViewController;
@property (nonatomic) MonthSelectorPurpose monthSelectorPurpose;
@property (nonatomic, strong) IAEContextMenuActionSheetViewController *contextMenuActionSheetViewController;
@property (nonatomic) BOOL waitingToConfirmRemoveAllConcepts;
@property (nonatomic) BOOL noteModeWasActivatedWithoutCalculator;
@property (nonatomic, weak) IAEEditModeConceptCollectionViewCell *longTapEditModeConceptCollectionViewCell;
@property (nonatomic, strong) IAEEasyIncomesAndExpensesQuery *easyIncomesAndExpensesQuery;
@end

@implementation IAEEasyIncomesAndExpensesViewController

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
    [self.conceptsCollectionView removeGestureRecognizer:self.swipeRightConceptsGestureRecognizer];
    [self.conceptsCollectionView removeGestureRecognizer:self.swipeLeftConceptsGestureRecognizer];
    [self.conceptsCollectionView removeGestureRecognizer:self.pinchConceptsGestureRecognizer];
    [self.editAndReportModeContentContainerView removeGestureRecognizer:self.tapEditAndReportModeContainerViewRecognizer];
    [self.editAndReportModeContentContainerView removeGestureRecognizer:self.longPressureConceptsGestureRecognizer];
}

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommonProperties];
        [self initQueryObject];
        [self initTapConceptsGestureRecognizer];
        [self initRightSwipeConceptsGestureRecognizer];
        [self initLeftSwipeConceptsGestureRecognizer];
        [self initPinchConceptsGestureRecognizer];
        [self initPanCalculatorGestureRecognizer];
        [self initLongPressureGestureRecognizer];
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

- (void)initQueryObject
{
    _easyIncomesAndExpensesQuery = [[IAEEasyIncomesAndExpensesQuery alloc] init];
    _easyIncomesAndExpensesQuery.dataSource = self;
}

- (void)initTapConceptsGestureRecognizer
{
    _tapConceptsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnConceptsCollectionView:)];
    _tapConceptsRecognizer.numberOfTapsRequired = 1;
    
    // TODO
    
    _tapEditAndReportModeContainerViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnConceptsCollectionView:)];
    _tapEditAndReportModeContainerViewRecognizer.numberOfTapsRequired = 1;
}

- (void)initRightSwipeConceptsGestureRecognizer
{
    _swipeRightConceptsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightOnConceptsCollectionView:)];
    _swipeRightConceptsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)initLeftSwipeConceptsGestureRecognizer
{
    _swipeLeftConceptsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftOnConceptsCollectionView:)];
    _swipeLeftConceptsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
}

-(void)initPinchConceptsGestureRecognizer
{
    _pinchConceptsGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOnConceptsCollectionView:)];
}

- (void)initPanCalculatorGestureRecognizer
{
    _panCalculatorGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnCalculatorView:)];
}

- (void)initLongPressureGestureRecognizer
{
    _longPressureConceptsGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressureOnConceptsCollectionView:)];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterInitialMonthChanged:)
                                                 name:kNotificationInitialMonthChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterMainNavitationTitleTouched:)
                                                 name:kNotificationMainLabelTitleTouched
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterKeyboardResignFromEditingConceptsNotes:)
                                                 name:kNotificationKeyboardResignFromEditingConceptsNotes
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterKeyboardSignForEditingConceptsNotes:)
                                                 name:kNotificationKeyboardSignForEditingConceptsNotes
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterEndEditingNoteForModeConceptCollectionViewCell:)
                                                 name:kNotificationEndEditingNoteForModeConceptCollectionViewCell
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
    _helperReportAreaViewDataSource = [[IAEHelperReportAreaViewDataSource alloc] initWithEasyIncomesViewControllerQuery:self.easyIncomesAndExpensesQuery];
    _helperContextTextRawMenuDataSource = [[IAEHelperContextTextRawMenuDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self.easyIncomesAndExpensesQuery];
    _helperReportTextRawMenuDataSource = [[IAEHelperReportTextRawMenuDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self.easyIncomesAndExpensesQuery];
    _helperCalculatorDataSource = [[IAEHelperCalculatorDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self.easyIncomesAndExpensesQuery];
    _helperConceptsCollectionViewDataSource = [[IAEHelperConceptsCollectionViewDataSource alloc] initWithEasyIncomesAndExpensesViewControllerQuery:self.easyIncomesAndExpensesQuery];
}

#pragma mark - ViewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self configureNavigationBar];
    [self configureSelectorContextView];
    [self configureEditModeSegmentedControl];
    [self configureCalculatorViewController];
    [self configureConceptsViews];
    [self configureReportAreaView];
    [self configureReportMenuView];
    
    // ToDo
    [self.editAndReportModeContentContainerView addGestureRecognizer:self.tapEditAndReportModeContainerViewRecognizer];
}

- (void)configureNavigationBar
{
    self.favoritesButton = [self makeBarButtonWithTitle:kLTextFavoritesBarButtonTitle andSelector:@selector(favoritesButtonPressed:)];
    self.categoriesButton = [self makeBarButtonWithTitle:kLTextCategoriesBarButtonTitle andSelector:@selector(categoriesButtonPressed:)];
    self.yearsButton = [self makeBarButtonWithTitle:kLTextYearsBarButtonTitle andSelector:@selector(yearsButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [[NSUserDefaults standardUserDefaults] isProVersionEnabled] ? @[self.favoritesButton, self.categoriesButton, self.yearsButton] : @[self.categoriesButton, self.yearsButton];
    
    self.settingsButton = [self makeBarButtonWithTitle:kLTextSettingsBarButtonTitle andSelector:@selector(settingsOptionPressed:)];
    self.navigationItem.leftBarButtonItems = @[self.settingsButton];
}

- (UIBarButtonItem *)makeBarButtonWithTitle:(NSString *)title andSelector:(SEL)selector
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(title, @"")
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:selector];

    return button;
}

- (void)configureSelectorContextView
{
    self.selectorContextView.delegate = self;
    self.selectorContextView.dataSource = self;
}

- (void)configureEditModeSegmentedControl
{
    [self.modeSegmentedControl setTitle:NSLocalizedString(kLTextModeSegmentedControlEditMode, @"") forSegmentAtIndex:kSegmentedControlIndexEditMode];
    [self.modeSegmentedControl setTitle:NSLocalizedString(kLTextModeSegmentedControlReportMode, @"") forSegmentAtIndex:kSegmentedControlIndexReportMode];
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
    UIImage *backgroundImage = [UIImage imageNamed:@"editconceptcontainerviewbackground"];
    self.editAndReportModeContentContainerViewBackground = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.editAndReportModeContentContainerView insertSubview:self.editAndReportModeContentContainerViewBackground
                                                 belowSubview:self.conceptsCollectionView];
}

- (void)configureConceptsCollectionView
{
    [self registerNibsForConceptsCollectionView];
    [self configurePropertiesForConceptsCollectionView];
    [self addConceptsCollectionViewGestureRecognizers];
}

- (void)registerNibsForConceptsCollectionView
{
    UINib *nibForConceptCell = [UINib nibWithNibName:kNibConceptCellName bundle:[NSBundle mainBundle]];
    [self.conceptsCollectionView registerNib:nibForConceptCell forCellWithReuseIdentifier:kIdConceptCellName];
    
    UINib *nibForConceptHeaderInYearMode = [UINib nibWithNibName:kNibConceptCellHeaderInYearModeName bundle:[NSBundle mainBundle]];
    [self.conceptsCollectionView registerNib:nibForConceptHeaderInYearMode
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:kCollectionViewHeaderIdentifier];
}

- (void)configurePropertiesForConceptsCollectionView
{
    self.conceptsCollectionView.backgroundColor = [UIColor clearColor];
    self.conceptsCollectionView.showsHorizontalScrollIndicator = NO;
    self.conceptsCollectionView.showsVerticalScrollIndicator = NO;
    self.conceptsCollectionView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.conceptsCollectionView.bounces = YES;
}

- (void)addConceptsCollectionViewGestureRecognizers
{
    [self.conceptsCollectionView addGestureRecognizer:self.tapConceptsRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.swipeRightConceptsGestureRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.swipeLeftConceptsGestureRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.pinchConceptsGestureRecognizer];
    [self.conceptsCollectionView addGestureRecognizer:self.longPressureConceptsGestureRecognizer];
}

- (void)configureReportAreaView
{
    self.reportAreaView.backgroundColor = [UIColor whiteColor];
    self.reportAreaView.opaque = YES;
}

- (void)configureReportMenuView
{
    self.reportMenuView.backgroundColor = [self.view.backgroundColor copy];
    self.reportMenuView.opaque = YES;
}

#pragma mark - ViewWillAppear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.helpModeActivated) {
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
        
        [self prepareViewForInitialAnimation];
    }
}

- (void)vinculeConceptsCollectionView
{
    self.conceptsCollectionView.delegate = self;
    self.conceptsCollectionView.dataSource = self.helperConceptsCollectionViewDataSource;
}

- (void)prepareViewForInitialAnimation
{
    self.containerViewForDynamicFX.alpha = 0.0;
    self.calculatorViewController.view.alpha = 0.0;
    self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x,
                                                            self.calculatorViewController.view.center.y + self.calculatorViewController.dragPanel.bounds.size.height);
    self.navigationController.navigationBar.alpha = 0;
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
    NSUInteger globalContextViewIndex = [self.easyIncomesAndExpensesQuery findTodayMonthContextViewGlobalIndexInSelectorContextView];
    [self gotoToContextViewWithIndex:globalContextViewIndex];
}

- (void)gotoToContextViewWithIndex:(NSUInteger)contextIndex
{
    [self.selectorContextView changeToContextViewOfIndex:contextIndex withAnimation:!self.initialPositioning];
}

#pragma mark - ViewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.helpModeActivated) {
        self.navigationController.navigationBar.alpha = 0;
        
        [self executeInitialAnimation];
        [self checkFixesExecuted];
    }
}

- (void)executeInitialAnimation
{
    self.navigationController.navigationBar.alpha = 0.0;
    self.calculatorViewController.view.alpha = 1.0;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:kDurationInitializationAnimationNavigationFadeIn animations:^{
        self.navigationController.navigationBar.alpha = 1.0;

    }];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:kDurationInitializationAnimationContextAndModesFadeIn animations:^{
        self.containerViewForDynamicFX.alpha = 1.0;
    }];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:kDurationInitializationAnimationTraslantionFadeIn animations:^{
        self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x,
                                                                self.calculatorViewController.view.center.y - self.calculatorViewController.dragPanel.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.delegate lauchCompleteInEasyIncomesAndExpensesViewController:self];
    }];
}

- (void)checkFixesExecuted
{
    if ([IAEFixRemoveCategoryActionLostInUnloadedYears defaultFix].resultReport.length > 0) {
        UIAlertView *checkFixesExecutedAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.alertview.subject", @"")
                                                                              message:NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.alertview.message", @"")
                                                                             delegate:self
                                                                    cancelButtonTitle:NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.alertview.ok", @"")
                                                                    otherButtonTitles:nil];
        [checkFixesExecutedAlertView show];
    }
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.conceptCellToRemove) {
        [self executeLogicAfterDissmisAlertViewConfirmationRemoveConceptWithButtonClickedAtIndex:buttonIndex];
    } else if (self.waitingToConfirmRemoveAllConcepts) {
        self.waitingToConfirmRemoveAllConcepts = NO;
        if (buttonIndex == 1) {
            [self deleteAllConceptsOfActualSelectionContextViewAndUpdateUserInterface];
        }
    } else {
        [self executeLogicAfterFixRemoveCategoryActionLostInUnloadedYearsAlertViewOk];
    }
}

- (void)executeLogicAfterDissmisAlertViewConfirmationRemoveConceptWithButtonClickedAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kAlertViewButtonCancelIndex) {
        [self doUndoRemoveConceptCellToRemove];
    } else if (buttonIndex == kAltertViewButtonConfirmationIndex) {
        [self doRemoveConceptCellToRemove];
    }
}

- (void)executeLogicAfterFixRemoveCategoryActionLostInUnloadedYearsAlertViewOk
{
    NSAssert([IAEFixRemoveCategoryActionLostInUnloadedYears defaultFix].resultReport.length > 0, @"Deberia de haber un reporte creado");
    
    MFMailComposeViewController *appEmailViewController = [[MFMailComposeViewController alloc] init];
    appEmailViewController.mailComposeDelegate = self;
    
    NSString *subject = NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.emailSubject", @"");
    [appEmailViewController setSubject:subject];
    [appEmailViewController setToRecipients:nil];
    
    NSString *beginMessage = NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.emailBeginMessage", @"");
    NSString *messageBody = [beginMessage stringByAppendingString:[IAEFixRemoveCategoryActionLostInUnloadedYears defaultFix].resultReport];
    [appEmailViewController setMessageBody:messageBody isHTML:NO];
    
    [self presentViewController:appEmailViewController animated:YES completion:nil];
}

#pragma mark - ControlEvents

- (void)favoritesButtonPressed:(id)sender
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self releaseLongPressureOnConceptsCollectionView];
    
    IAEFavoriteConceptsViewController *favoriteConceptsViewController = [[IAEFavoriteConceptsViewController alloc] initWithOptions:FC_REMOVE];
    favoriteConceptsViewController.delegate = self;
    favoriteConceptsViewController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:favoriteConceptsViewController animated:YES completion:nil];
}

- (void)categoriesButtonPressed:(id)sender
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self releaseLongPressureOnConceptsCollectionView];

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
    //self.categoriesSelectorViewController.conceptCellIndexPath = ;
    
    [self presentViewController:self.categoriesSelectorViewController animated:YES completion:nil];
}

- (void)yearsButtonPressed:(id)sender
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self releaseLongPressureOnConceptsCollectionView];

    [self openModalForPresentYearSelectorViewController];
}

- (void)stopConceptsCollectionViewScrollAtActualPosition
{
    CGPoint offset = self.conceptsCollectionView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.conceptsCollectionView setContentOffset:offset animated:NO];
    
    offset.x += 1.0;
    offset.y += 1.0;
    [self.conceptsCollectionView setContentOffset:offset animated:NO];
}

- (void)stopConceptsCollectionViewScrollAtTop
{
    CGRect frame = CGRectMake(0.0, 0.0, self.conceptsCollectionView.bounds.size.width, self.conceptsCollectionView.bounds.size.height);
    [self.conceptsCollectionView scrollRectToVisible:frame animated:NO];
}

- (void)openModalForPresentYearSelectorViewController
{
    self.yearSelectorViewController = [[IAEYearSelectorViewController alloc] initWithNibName:nil bundle:nil];
    self.yearSelectorViewController.delegate = self;
    self.yearSelectorViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.yearSelectorViewController animated:YES completion:^{
        [self stopConceptsCollectionViewScrollAtActualPosition];
    }];
}

- (void)settingsOptionPressed:(id)sender
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self releaseLongPressureOnConceptsCollectionView];

    self.aboutAndOptions2ViewController = [[IAESettingsViewController alloc] initWithNibName:nil bundle:nil];
    self.aboutAndOptions2ViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.aboutAndOptions2ViewController animated:YES completion:nil];
}

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender
{
    [self releaseLongPressureOnConceptsCollectionView];

    if ([self.easyIncomesAndExpensesQuery isEditModeActive]) {
        [self updateAfterChangeToEditMode];
    } else if ([self.easyIncomesAndExpensesQuery isReportModeActive]) {
        [self updateAfterChangeToReportMode];
    }
}

- (void)updateAfterChangeToEditMode
{
    [Crashlytics setObjectValue:@"Edit" forKey:@"Mode"];

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
        [self reloadContentOfConceptsCollectionView];
        self.conceptsCollectionView.hidden = NO;
        self.calculatorViewController.view.hidden = NO;
        self.editAndReportModeContentContainerViewBackground.hidden = NO;
        [UIView animateWithDuration:kDurationModeFadeIn animations:^{
            self.withoutConceptsWarningInMonthEditModeView.alpha = [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext] > 0 ? 0.0 : 1.0;
            self.editAndReportModeContentContainerView.alpha = 1.0;
            self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x, self.calculatorViewController.view.center.y - self.calculatorViewController.dragPanel.bounds.size.height);
        } completion:^(BOOL finished) {
            [self updateCalculatorViewHideHalfState];
        }];
    }];
}


- (void)updateAfterChangeToReportMode
{
    [Crashlytics setObjectValue:@"Report" forKey:@"Mode"];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationModeFadeOut animations:^{
        self.editAndReportModeContentContainerView.alpha = 0.0;
        self.calculatorViewController.view.center = CGPointMake(self.calculatorViewController.view.center.x, self.calculatorViewController.view.center.y + self.calculatorViewController.dragPanel.bounds.size.height);
    } completion:^(BOOL finished) {
        self.withoutConceptsWarningInMonthEditModeView.alpha = 0;
        self.reportMenuView.currentOptionIndexSelected = 0;
        self.reportAreaView.dataSource = self.helperReportAreaViewDataSource;
        self.reportAreaView.reportAreaViewDelegate = self;
        self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y + self.reportMenuView.bounds.size.height);
        self.reportAreaView.hidden = NO;
        self.reportMenuView.hidden = NO;
        self.conceptsCollectionView.hidden = YES;
        self.calculatorViewController.view.hidden = YES;
        self.editAndReportModeContentContainerViewBackground.hidden = YES;
        [UIView animateWithDuration:kDurationModeFadeIn animations:^{
            self.withoutConceptsWarningInMonthReportModeView.alpha = [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext] > 0 ? 0.0 : 1.0;
            self.editAndReportModeContentContainerView.alpha = 1.0;
            self.reportMenuView.center = CGPointMake(self.reportMenuView.center.x, self.reportMenuView.center.y - self.reportMenuView.bounds.size.height);
        } completion:^(BOOL finished) {
            self.reportMenuView.optionsEnabled = [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext];
            self.reportMenuView.currentOptionIndexSelected = kReportMenuIndexOfBalancesOption;
        }];
    }];
}

#pragma mark - IAEEasyIncomesAndExpensesQueryDataSource

- (IAECategorySelectorViewController *)categorySelectorViewControllerForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.categoriesSelectorViewController;
}

- (UIPopoverController *)currentPopoverForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.popover;
}

- (IAESelectorContextView *)selectorContextViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.selectorContextView;
}

- (UICollectionView *)conceptsCollectionViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.conceptsCollectionView;
}

- (UISegmentedControl *)modeSegmentedControlForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.modeSegmentedControl;
}

- (IAECalculatorViewController *)calculatorViewControllerForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.calculatorViewController;
}

- (IAETextRawSelectorMenuView *)contextMenuViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.contextMenuView;
}

- (IAETextRawSelectorMenuView *)reportMenuViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.reportMenuView;
}

- (NSArray *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:(NSIndexPath *)indexPath
{
    return [self.easyIncomesAndExpensesQuery allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:indexPath];
}

- (UICollectionView *)findConceptsCollectionViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.conceptsCollectionView;
}

- (CGSize)findMainViewSizeForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return self.view.bounds.size;
}

- (IAEMonth *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery findMonthForOpenYearAtIndex:(NSUInteger)index
{
    return [self.easyIncomesAndExpensesQuery findMonthForOpenYearAtIndex:index];
}

- (NSArray *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type
{
    return [self.easyIncomesAndExpensesQuery findCategoriesOfActualSelectedContextViewWithType:type];
}

- (GlobalModeType)findGlobalModeTypeForConceptsEditModeForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery
{
    return [self findGlobalModeTypeForConceptsEditMode];
}

#pragma mark - Update

- (void)updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:(BOOL)animation
{
    if (![self.calculatorViewController isOpen]) {
        [self updateSelectedMonthBalanceWithAnimation:animation];
        [self updateOpenYearBalance];
    }
}

- (void)updateSelectedMonthBalanceWithAnimation:(BOOL)animation
{
    IAEContextView *contextView = [self.easyIncomesAndExpensesQuery findActualSelectedMonthContextView];
    if (animation) {
        [contextView reloadDataWithAnimationFromUsingZeroValue:NO];
    } else {
        [contextView reloadDataWithoutAnimation];
    }
}

- (void)updateOpenYearBalance
{
    IAEContextView *contextView = [self.easyIncomesAndExpensesQuery findOpenYearContextView];
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
        NSUInteger valueIndex = index == yearIndex ? [self.easyIncomesAndExpensesQuery findOpenYear].yearDate : January + index - 1;
        [self addToSelectorContextViewWithGlobalPosition:index contextType:contextViewType andValueIndex:valueIndex];
    }
}

- (void)addToSelectorContextViewWithGlobalPosition:(NSUInteger)globalPosition
                                            contextType:(IAEContextViewType)contextType
                                          andValueIndex:(NSUInteger)contextValueIndex
{
    CGRect frame = CGRectMake(0,
                              kSelectorContextViewYOutsideMargin,
                              self.selectorContextView.bounds.size.width,
                              self.selectorContextView.bounds.size.height - kSelectorContextViewYOutsideMargin);
    IAEContextView *contextView = [[IAEContextView alloc] initWithFrame:frame type:contextType andValueIndex:contextValueIndex];
    contextView.dataSource = self;
    
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
        [self performActionsAfterDismissAdjustConceptAmountPopover:popoverController];
    } else if ([popoverController.contentViewController isKindOfClass:[IAEDayCalendarSelectorViewController class]]) {
        [self performActionsAfterDismissDayCalendarSelectorPopover:popoverController];
    } else if ([popoverController.contentViewController isKindOfClass:[IAECategorySelectorViewController class]]) {
        [self performActionsAfterDismissCategorySelectorPopover:popoverController];
    } else if ([popoverController.contentViewController isKindOfClass:[IAEMonthSelectorViewController class]]) {
        [self performActionsAfterMonthSelectorViewController:popoverController];
    } else if ([popoverController.contentViewController isKindOfClass:[IAEContextMenuActionSheetViewController class]]) {
        [self performActionsAfterContextMenuActionSheetViewController:popoverController];
    }
    
    self.popover = nil;
}

- (void)performActionsAfterDismissAdjustConceptAmountPopover:(UIPopoverController *)popoverController
{
    [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:YES];
    IAEAdjustConceptAmountViewController *controller = (IAEAdjustConceptAmountViewController *)popoverController.contentViewController;
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:controller.conceptCellIndexPath];
    [cell setVisualAspectInEditMode:NO forConceptElement:EditModeConceptElement_Amount];
}

- (void)performActionsAfterDismissDayCalendarSelectorPopover:(UIPopoverController *)popoverController
{
    IAEDayCalendarSelectorViewController *controller = (IAEDayCalendarSelectorViewController *)popoverController.contentViewController;
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:controller.conceptCellIndexPath];
    [cell setVisualAspectInEditMode:NO forConceptElement:EditModeConceptElement_DayOrNumberInstance];
}

- (void)performActionsAfterDismissCategorySelectorPopover:(UIPopoverController *)popoverController
{
    IAECategorySelectorViewController *controller = (IAECategorySelectorViewController *)popoverController.contentViewController;
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:controller.conceptCellIndexPath];
    [cell setVisualAspectInEditMode:NO forConceptElement:EditModeConceptElement_Category];
}

- (void)performActionsAfterMonthSelectorViewController:(UIPopoverController *)popover
{
    self.monthSelectorViewController = nil;
}

- (void)performActionsAfterContextMenuActionSheetViewController:(UIPopoverController *)popover
{
    self.contextMenuActionSheetViewController = nil;
}

- (void)updateBalancesIfDismissFromAdjustConceptAmountPopover:(UIPopoverController *)popover
{
    if ([popover.contentViewController isKindOfClass:[IAEAdjustConceptAmountViewController class]]) {
        [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:YES];
    }
}

#pragma mark - IAEReportAreaViewDelegate

- (void)reloadDataWithAnimationWasDoneInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:!self.initialPositioning];
    [self disableOrEnableReportMenuIfAppropiate];
}

#pragma mark - IAESelectorContextView DataSource

- (NSUInteger)numberOfConceptsForSelectorContextView:(IAESelectorContextView *)selectorContextView atIndex:(NSUInteger)index
{
    NSUInteger retNumberOfConcepts = 0;
    
    IAEMonth *actualMonth = [self.easyIncomesAndExpensesQuery findActualSelectedMonth];
    if (actualMonth) {
        retNumberOfConcepts = actualMonth.concepts.count;
    } else {
        IAEOpenYear *openYear = [self.easyIncomesAndExpensesQuery findOpenYear];
        retNumberOfConcepts = [openYear findNumberOfConcepts];
    }
    
    return retNumberOfConcepts;
}

#pragma mark - IAESelectorContextView Delegate

- (void)selectorContextView:(IAESelectorContextView *)selectorContextView didChangeToContextViewAtIndex:(NSUInteger)index
{
    if ([self isContextMenuOptionPending]) {
        [self processNextContextMenuOptionPending];
    } else {
        [self updateContentInformationBasedInCurrentContextWithAnimation:!self.initialPositioning];
    }
}

- (void)updateContentInformationBasedInCurrentContextWithAnimation:(BOOL)animation
{
    [self updateCurrentOptionIndexSelectedOfContextMenu];
    [self updateContentInformationOfActualModeWithAnimation:animation];
}

- (void)updateContentInformationOfActualModeWithAnimation:(BOOL)animation
{
    if ([self.easyIncomesAndExpensesQuery isEditModeActive]) {
        [self updateConceptsCollectionViewWithAnimation:animation];
        [self updateCalculatorViewHideHalfState];
    } else if ([self.easyIncomesAndExpensesQuery isReportModeActive]) {
        // Si hay aviso de que venimos de un contexto sin conceptos, primero comprobamos si hay que quitarlo y luego recargamos.
        // Si NO venimos del caso anterior, primero recargamos y luego, en el delegado, comprobamos si estamos en un contexto sin conceptos
        // NOTA: En el primer caso también llamamos al delegado y volvemos a ejecutar showWithout... pero no pasara nada ya que el estado se habra
        // establecido en la primera llamada.
        if ([self isAnyWithoutConceptsWarningViewVisible]) {
            [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation andExecuteAfterAnimationTheLogicBlock:^{
                [self reloadContentOfConceptsReportViewWithAnimation:animation];
            }];
        } else {
            [self reloadContentOfConceptsReportViewWithAnimation:animation];
        }
    }
}

- (BOOL)isContextMenuOptionPending
{
    const BOOL is = self.lastContextIndexMenuPressed != kInvalidOptionIndex;
    
    return is;
}

- (void)processNextContextMenuOptionPending
{
    NSAssert([self isContextMenuOptionPending], @"");
    
    [self.selectorContextView changeToContextViewOfIndex:self.lastContextIndexMenuPressed withAnimation:YES];
    self.lastContextIndexMenuPressed = kInvalidOptionIndex;
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
            [self reloadContentOfConceptsCollectionView];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:kDurationOfEditConceptCollectionViewTransition animations:^{
                self.conceptsCollectionView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [self executePendingScrollToEditModeConceptCellIfAppropiate];
            }];
        }];
    } else {
        [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:NO];
        [self reloadContentOfConceptsCollectionView];
    }
}

- (void)executePendingScrollToEditModeConceptCellIfAppropiate
{
    if (self.pendingScrollToEditModeConceptCellIndexPath) {
        [self.conceptsCollectionView performBatchUpdates:^{
            [self.conceptsCollectionView scrollToItemAtIndexPath:self.pendingScrollToEditModeConceptCellIndexPath
                                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                        animated:NO];
            
        } completion:^(BOOL finished) {
            IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:self.pendingScrollToEditModeConceptCellIndexPath];
            [cell doCallForAttentionAnimation];
            self.pendingScrollToEditModeConceptCellIndexPath = nil;
        }];
    }
}

- (void)disableOrEnableReportMenuIfAppropiate
{
    self.reportMenuView.optionsEnabled = [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext];
}

- (void)showWithoutConceptsWarningViewIfAppropriateWithAnimation:(BOOL)animation
{
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:animation andExecuteAfterAnimationTheLogicBlock:nil];
}

- (void)showWithoutConceptsWarningViewIfAppropriateWithAnimation:(BOOL)animation
                           andExecuteAfterAnimationTheLogicBlock:(void(^)(void))logicBlock
{
    const BOOL show = [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext] == 0;
    CGFloat alpha = show ? 1.0 : 0.0;
    
    void(^ alphaChanges)(void) = ^(void) {
        if ([self.easyIncomesAndExpensesQuery isEditModeActive]) {
            self.withoutConceptsWarningInMonthEditModeView.alpha = alpha;
            self.withoutConceptsWarningInMonthReportModeView.alpha = 0;
        } else if ([self.easyIncomesAndExpensesQuery isReportModeActive]) {
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
    if ([self.easyIncomesAndExpensesQuery isActualSelectedContextTheYearOpen]) {
        [self.calculatorViewController disable];
    } else {
        [self.calculatorViewController enable];
    }
}

- (BOOL)isHideHalfCalculatorViewEnabled
{
    return YES;
}

- (void)reloadContentOfConceptsReportViewWithAnimation:(BOOL)animation
{
    [self.reportAreaView reloadDataWithAnimation:YES];
}

- (void)reloadContentOfConceptsCollectionView
{
    [self stopConceptsCollectionViewScrollAtTop];
    [self.conceptsCollectionView reloadData];
}

#pragma mark - IAEContextViewDataSource

- (NSString *)nameForContextView:(IAEContextView *)contextView
{
    NSString *name = nil;
    
    IAEOpenYear *year = [self.easyIncomesAndExpensesQuery findOpenYear];
    if (contextView.contextType == CONTEXT_VIEW_MONTH) {
        IAEMonth *month = [year.months objectAtIndex:contextView.valueIndex - 1];
        name = [month monthAsString];
    } else if (contextView.contextType == CONTEXT_VIEW_YEAR) {
        name = [year yearDateAsString];
    }
    
    return name;
}

- (NSDecimalNumber *)balanceForContextView:(IAEContextView *)contextView
{
    NSDecimalNumber *balance = nil;
    
    IAEOpenYear *openYear = [self.easyIncomesAndExpensesQuery findOpenYear];
    if (contextView.contextType == CONTEXT_VIEW_MONTH) {
        IAEMonth *month = [openYear.months objectAtIndex:contextView.valueIndex - 1];
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
    IAEOpenYear *year = [self.easyIncomesAndExpensesQuery findOpenYear];
    IAEMonth *month = [year.months objectAtIndex:monthIndex];

    return month;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeZero;
    if ([self.easyIncomesAndExpensesQuery isActualSelectedContextTheYearOpen]) {
        headerSize = [IAEEditModeConceptCollectionViewHeader sizeOfItem];
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
    if (![self.easyIncomesAndExpensesQuery isDayModeActiveForConcepts]) {
        [self updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsBeforeIndexPath:indexPathLimit];
    }
}

- (void)updateIdentifierWithEntryInstanIndexForVisibleConceptViewCellsBeforeIndexPath:(NSIndexPath *)indexPathLimit
{
    NSUInteger numberOfItems = [self.easyIncomesAndExpensesQuery findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:indexPathLimit.section];
    for (IAEEditModeConceptCollectionViewCell *cellVisible in self.conceptsCollectionView.visibleCells) {
        NSIndexPath *indexPathOfVisibleCell = [self.conceptsCollectionView indexPathForCell:cellVisible];
        if (indexPathOfVisibleCell.row < indexPathLimit.row) {
            NSUInteger instantEntryIndex =  numberOfItems - indexPathOfVisibleCell.row;
            CGFloat animationDuration = KDurationOfAnimationUpdateForEntryInstantIndex;
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
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];

    if ([[NSUserDefaults standardUserDefaults] isRemoveConceptConfirmationActive] && [[NSUserDefaults standardUserDefaults] isProVersionEnabled]) {
        [self lauchAlertViewToConfirmRemoveOfStrokedConceptCell];
    } else {
        [self performSelector:@selector(doRemoveConceptCellToRemove) withObject:nil afterDelay:kDelayToExecuteRemoveConceptCell];
    }
}

- (void)lauchAlertViewToConfirmRemoveOfStrokedConceptCell
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_CONFIRMREMOVECONCEPT_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_ALERTVIEW_CONFIRMREMOVECONCEPT_MESSAGE", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_CONFIRMREMOVECONCEPT_NO", @"")
                                              otherButtonTitles:NSLocalizedString(@"LTEXT_ALERTVIEW_CONFIRMREMOVECONCEPT_YES", @""), nil];
    [alertView show];
}

- (void)doRemoveConceptCellToRemove
{
    [self removeConceptAndUpdateBalancesOfCell:self.conceptCellToRemove withAnimation:YES];
}

- (void)doUndoRemoveConceptCellToRemove
{
    [self.strokeAnimatableLineView resetStroke];
    [self.conceptCellToRemove exitFromStrokeState];
    self.conceptCellToRemove = nil;
}

#pragma mark - UIPanGestureRecognizer

- (void)panOnCalculatorView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([self canPanCalculator]) {
        [self doPanCalculatorWithGesture:panGestureRecognizer];
    }
}

- (BOOL)canPanCalculator
{
    const BOOL canPan = !self.calculatorViewController.isInDisableMode;
    
    return canPan;
}

- (void)doPanCalculatorWithGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self releaseLongPressureOnConceptsCollectionView];
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

#pragma mark - UILongPressureGestureRecognizer

- (void)longPressureOnConceptsCollectionView:(UILongPressGestureRecognizer *)longPressureGestureRecognizer
{
    if ([self canExecuteLongPressureOnConceptsCollectionView]) {
        if (longPressureGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            if (![self isGlobalModeTypeNote]) {
                [self acquiresLongPressureOnConceptsCollectionViewFromGesture:longPressureGestureRecognizer];
            }
        } else if (longPressureGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self releaseLongPressureOnConceptsCollectionView];
        }
    }
}

- (BOOL)canExecuteLongPressureOnConceptsCollectionView
{
    return [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
}

- (BOOL)isGlobalModeTypeNote
{
    return [self findGlobalModeTypeForConceptsEditMode] == GlobalModeTypeNote;
}

- (void)acquiresLongPressureOnConceptsCollectionViewFromGesture:(UILongPressGestureRecognizer *)longPressureGestureRecognizer
{
    if (!self.longTapEditModeConceptCollectionViewCell) {
        IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:longPressureGestureRecognizer];
        if ([cell isNoteDescriptionPresent]) {
            [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
            self.longTapEditModeConceptCollectionViewCell = cell;
            [self.longTapEditModeConceptCollectionViewCell changeToNoteModeWithAnimation:YES];
        }
    }
}

- (void)releaseLongPressureOnConceptsCollectionView
{
    if (self.longPressureConceptsGestureRecognizer) {
        [self.longTapEditModeConceptCollectionViewCell changeToDataModeWithAnimation:YES];
        self.longTapEditModeConceptCollectionViewCell = nil;
    }
}

#pragma mark - UIPinchGestureRecognizer

// REFACTORIZAR

- (void)pinchOnConceptsCollectionView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if ([self canExecutePinchOnConceptsColletionView]) {
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self beginPinchForConceptsCollectionView];
        }
        
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
            pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateVisibleConceptsCollectionViewCellsForChangeToAppropiateModeWithPinchGestureRecognizer:pinchGestureRecognizer];
        } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self releaseCurrentPinchGestureRecognizerIfAppropiate];
        }
        
        pinchGestureRecognizer.scale = 1;
    }
}

- (void)releaseCurrentPinchGestureRecognizerIfAppropiate
{
    self.noteModeWasActivatedWithoutCalculator = NO;
    
    GlobalModeType globalModeType = [self findGlobalModeTypeForConceptsEditMode];
    if (globalModeType != GlobalModeTypeNone) {
        IAEEditModeConceptCollectionViewCell *cell = self.conceptsCollectionView.visibleCells[0];
        const GlobalModeType cellGlobalModeTypeData = [cell findGlobalModeTypeIfUpdatingEndsRightNow];
        if (cellGlobalModeTypeData == GlobalModeTypeData) {
            [self changeVisibleConceptsCollectionViewCellsToDataModeWithAnimation:YES];
        } else if (cellGlobalModeTypeData == GlobalModeTypeNote) {
            [self changeVisibleConceptsCollectionViewCellsToNoteModeWithAnimation:YES];
        } else if (cellGlobalModeTypeData == GlobalModeTypeUpdating) {
            NSAssert(0, @"No deberia de darse nunca esgte caso");
        }
    }
    
    [self endPinchForConceptsCollectionView];
}

- (BOOL)canExecutePinchOnConceptsColletionView
{
    const BOOL can = ![self.easyIncomesAndExpensesQuery isActualSelectedContextTheYearOpen] &&
                     [self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext] &&
                     [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
    
    return can;
}

- (void)beginPinchForConceptsCollectionView
{
    [self preloadKeyboard];
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    self.conceptsCollectionView.scrollEnabled = NO;
}

- (void)preloadKeyboard
{
    // Necesitamos precargar el teclado para asegurarnos de que la primera vez que se lance ya este en memoria o de lo contrario
    // la animacion que se ejecute con el ira muy lenta si tiene carga visual importante. Esto lo hemos visto cuando hemos ejecutado
    // la animacion de desplazamiento de conceptos al querer editar la descripción de uno.
    UITextField *field = [UITextField new];
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:field];
    [field becomeFirstResponder];
    [field resignFirstResponder];
    [field removeFromSuperview];
}

- (void)endPinchForConceptsCollectionView
{
    self.conceptsCollectionView.scrollEnabled = YES;
}

- (void)updateVisibleConceptsCollectionViewCellsForChangeToAppropiateModeWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.scale > 1.0) {
        [self updateVisibleConceptsCollectionViewCellsChangeToNoteModeWithPinchGestureRecognizer:pinchGestureRecognizer];
    } else {
        [self updateVisibleConceptsCollectionViewCellsChangeToDataModeWithPinchGestureRecognizer:pinchGestureRecognizer];
    }
}

- (void)updateVisibleConceptsCollectionViewCellsChangeToNoteModeWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self.conceptsCollectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEEditModeConceptCollectionViewCell *cell = obj;
        [cell updateChangeToNoteMode:pinchGestureRecognizer.scale - 1.0];
    }];
}

- (void)updateVisibleConceptsCollectionViewCellsChangeToDataModeWithPinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    [self.conceptsCollectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEEditModeConceptCollectionViewCell *cell = obj;
        [cell updateChangeToDataMode:1.0 - pinchGestureRecognizer.scale];
    }];
}

- (void)updateVisibleConceptsCollectionViewCellsChangeToDataMode
{
    [self.conceptsCollectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEEditModeConceptCollectionViewCell *cell = obj;
        [cell changeToDataModeWithAnimation:YES];
    }];
}

- (void)changeVisibleConceptsCollectionViewCellsToDataModeWithAnimation:(BOOL)animation
{
    [self.conceptsCollectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEEditModeConceptCollectionViewCell *cell = obj;
        [cell changeToDataModeWithAnimation:animation];
    }];
}

- (void)changeVisibleConceptsCollectionViewCellsToNoteModeWithAnimation:(BOOL)animation
{
    [self.conceptsCollectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEEditModeConceptCollectionViewCell *cell = obj;
        [cell changeToNoteModeWithAnimation:animation];
    }];
}

- (GlobalModeType)findGlobalModeTypeForConceptsEditMode
{
    GlobalModeType cellGlobalModeTypeData = GlobalModeTypeNone;
    if (self.conceptsCollectionView.visibleCells.count > 0) {
        IAEEditModeConceptCollectionViewCell *cell = self.conceptsCollectionView.visibleCells[0];
        cellGlobalModeTypeData = [cell findGlobalModeTypeIfUpdatingEndsRightNow];
    }
    
    return cellGlobalModeTypeData;
}

#pragma mark - UISwipeGestureRecognizer

- (void)swipeLeftOnConceptsCollectionView:(UIGestureRecognizer *)swipeGestureRecognizer
{
    // Nota: Puede venir un concepto nulo por hacer swipe en una zona hueca
    IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:swipeGestureRecognizer];
    if (cell && [self canDoLeftSwipeOnConceptsCollectionViewCell:cell]) {
        if ([self isCompletelyVisibleConceptCollectionViewCell:cell]) {
            [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
            [cell scrollToMenuMode];
        } else {
            [self scrollToConceptsCollectionViewCell:cell];
        }
    }
}

- (BOOL)canDoLeftSwipeOnConceptsCollectionViewCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    const BOOL can = [self.easyIncomesAndExpensesQuery isActualSelectedContextAMonth] &&
                     ![self.easyIncomesAndExpensesQuery isNoteModeActiveInConcepts] &&
                     ![self.calculatorViewController isAnyTranslationActive] &&
                     !self.conceptCellToRemove &&
                     !cell.menuModeActive &&
                     [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
    
    return can;
}

- (void)swipeRightOnConceptsCollectionView:(UIGestureRecognizer *)swipeGestureRecognizer
{
    if ([self canDoRightSwipeOnConceptsCollectionView]) {
        // Nota: Puede venir un concepto nulo por hacer strike en una zona hueca
        IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:swipeGestureRecognizer];
        if (cell) {
            if (cell.menuModeActive) {
                [cell scrollToNormalModeUsingAnimation:YES];
            } else if ([self isCompletelyVisibleConceptCollectionViewCell:cell]) {
                [self doStrokeOverConceptCell:cell];
            } else {
                [self scrollToConceptsCollectionViewCell:cell];
            }
        }
    }
}

- (BOOL)canDoRightSwipeOnConceptsCollectionView
{
    const BOOL can = [self.easyIncomesAndExpensesQuery isActualSelectedContextAMonth] &&
                     ![self.easyIncomesAndExpensesQuery isNoteModeActiveInConcepts] &&
                     ![self.calculatorViewController isAnyTranslationActive] &&
                     !self.conceptCellToRemove;
    
    return can;
}

- (void)doStrokeOverConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    self.conceptCellToRemove = cell;
    self.conceptCellToRemove.durationOfStrokeStateTransition = self.strokeAnimatableLineView.durationOfStrokeAnimation;
    [self.strokeAnimatableLineView doStrokeOverTheView:self.conceptCellToRemove.conceptInformationContainerView];
    [self.conceptCellToRemove goToStrokeState];
}

#pragma mark - UITapGestureRecognizer

- (void)tapOnConceptsCollectionView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSAssert(tapGestureRecognizer == self.tapConceptsRecognizer || tapGestureRecognizer == self.tapEditAndReportModeContainerViewRecognizer, @"");
    IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:tapGestureRecognizer];
    if ([self canTapOnConceptCollectionViewCell:cell]) {
        if ([self.easyIncomesAndExpensesQuery isActualSelectedContextAMonth] ) {
            [self executeActionInMonthContextOnCellOfConceptCollectionView:cell underLocatonOfTapGestureRecognizer:tapGestureRecognizer];
        } else if ([self.easyIncomesAndExpensesQuery isActualSelectedContextTheYearOpen]) {
            [self executeActionInYearContextOnCellOfConceptCollectionView:cell];
        }
    }
}

- (BOOL)canTapOnConceptCollectionViewCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    const BOOL can = cell &&
                     ![self.calculatorViewController isAnyTranslationActive] &&
                     ![self.easyIncomesAndExpensesQuery isNoteModeActiveInConcepts];
    
    return can;
}

- (void)findCellOfConceptCollectionViewAndExecuteActionUnderTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    IAEEditModeConceptCollectionViewCell *cell = [self findConceptCellUnderLocationOfGestureRecognizer:tapGestureRecognizer];
    [self executeActionInMonthContextOnCellOfConceptCollectionView:cell underLocatonOfTapGestureRecognizer:tapGestureRecognizer];
}

- (IAEEditModeConceptCollectionViewCell *)findConceptCellUnderLocationOfGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [self extractConceptCollectionViewLocationFromGestureRecognizer:gestureRecognizer];
    NSIndexPath *locationIndexPath = [self.conceptsCollectionView indexPathForItemAtPoint:location];
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:locationIndexPath];
    
    return cell;
}

- (CGPoint)extractConceptCollectionViewLocationFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = CGPointZero;
    if ([self isAConceptCollectionViewGestureRecognizer:gestureRecognizer]) {
        location = [gestureRecognizer locationInView:self.conceptsCollectionView];
    } else if (gestureRecognizer == self.tapEditAndReportModeContainerViewRecognizer) {
        location = [gestureRecognizer locationInView:self.editAndReportModeContentContainerView];
        location = [self.conceptsCollectionView convertPoint:location fromView:self.editAndReportModeContentContainerView];
        location = CGPointMake(MAX(0, location.x), location.y);
        location = CGPointMake(MIN(location.x, self.conceptsCollectionView.frame.size.width), location.y);
    }

    return location;
}

- (BOOL)isAConceptCollectionViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    return gestureRecognizer == self.tapConceptsRecognizer ||
           gestureRecognizer == self.swipeRightConceptsGestureRecognizer ||
           gestureRecognizer == self.swipeLeftConceptsGestureRecognizer ||
           gestureRecognizer == self.longPressureConceptsGestureRecognizer;
}

- (void)executeActionInYearContextOnCellOfConceptCollectionView:(IAEEditModeConceptCollectionViewCell *)cell
{
    NSIndexPath *indexPathOfCell = [self.conceptsCollectionView indexPathForCell:cell];
    NSArray *monthWithConcepts = [self.easyIncomesAndExpensesQuery findAllOrdererMonthsWithConceptsOfOpenYear];
    IAEMonth *month = [monthWithConcepts objectAtIndex:indexPathOfCell.section];
    self.pendingScrollToEditModeConceptCellIndexPath = [NSIndexPath indexPathForRow:indexPathOfCell.row inSection:0];

    IAEOpenYear *openYear = [self.easyIncomesAndExpensesQuery findOpenYear];
    const NSUInteger monthIndex = [openYear findIndexOfMonth:month.month];
    [self.selectorContextView changeToContextViewOfIndex:monthIndex + 1 withAnimation:YES];
}

- (void)executeActionInMonthContextOnCellOfConceptCollectionView:(IAEEditModeConceptCollectionViewCell *)cell
                   underLocatonOfTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self isCompletelyVisibleConceptCollectionViewCell:cell]) {
        [self executeLogicForManipulateConceptsCollectionViewCell:cell
                               underLocatonOfTapGestureRecognizer:gestureRecognizer];
    } else {
        [self scrollToConceptsCollectionViewCell:cell];
    }
}

- (BOOL)isCompletelyVisibleConceptCollectionViewCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    const CGRect frameOfCell = [self.conceptsCollectionView convertRect:cell.frame toView:self.conceptsCollectionView.superview];
    const BOOL isCompletely = CGRectContainsRect(self.conceptsCollectionView.frame, frameOfCell);
    
    return isCompletely;
}

- (void)scrollToConceptsCollectionViewCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];
    [self.conceptsCollectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)executeLogicForManipulateConceptsCollectionViewCell:(IAEEditModeConceptCollectionViewCell *)cell
                                  underLocatonOfTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [self convertLocationToCellArea:cell fromGestureRecognizer:gestureRecognizer];
    if (cell.menuModeActive) {
        if ([cell isDuplicateOptionContainingLocationPoint:location]) {
            [self executeDuplicateConceptOfCell:cell];
        } else if ([cell isMoveOptionContainingLocationPoint:location]) {
            [self openPopoverForSelectMonthToMoveConceptCell:cell];
        } else if ([cell isCopyOptionContainingLocationPoint:location]) {
            [self openPopoverForSelectMonthToCopyConceptCell:cell];
        }
    } else {
        if ([cell isFavoritePinContainingLocationPoint:location] && [self isFavoritePinInteractionEnabledInConcepts]) {
            [self executeLogicAfterFavoritePinTapForCell:cell];
        } else if ([cell isAmountLabelContainingLocationPoint:location]) {
            [self openPopoverForAdjustAmountOfConceptCell:cell];
        } else if ([cell isCategoryNameOrTypeContainingLocationPoint:location]) {
            [self openPopoverForEditCategoryOfConceptCell:cell];
        } else if ([cell isIdentifierOrDayContainingLocationPoint:location] && [self.easyIncomesAndExpensesQuery isDayModeActiveForConcepts]) {
            [self openPopoverForSelectDayOfConceptCell:cell];
        }
    }
}

- (void)executeDuplicateConceptOfCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptOfCell:cell];
    IAEConcept *newConcept = [concept.month duplicateConcept:concept];
    [[IAEBook sharedBook] saveAll];
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self updateAfterNewConceptCreated:newConcept withCallForAttentionAnimation:YES];
}

- (void)openPopoverForSelectMonthToCopyConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    [self openPopoverForSelectMonthFromCell:cell withPurpose:MonthSelectorPurposeCopy inDestinationView:[cell viewOfCopyMenuOption]];
}

- (void)openPopoverForSelectMonthToMoveConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    [self openPopoverForSelectMonthFromCell:cell withPurpose:MonthSelectorPurposeMove inDestinationView:[cell viewOfMoveMenuOption]];
}

- (void)openPopoverForSelectMonthFromCell:(IAEEditModeConceptCollectionViewCell *)cell withPurpose:(MonthSelectorPurpose)purpose inDestinationView:(UIView *)destinationView
{
    self.monthSelectorViewController = [self createMonthSelectorViewControllerFromActualState];
    self.monthSelectorPurpose = purpose;
    [self createAndPresentPopoverForConceptCellView:destinationView withViewController:self.monthSelectorViewController];
}

- (IAEMonthSelectorViewController *)createMonthSelectorViewControllerFromActualState
{
    IAEMonthSelectorViewController *monthSelectorViewController = [[IAEMonthSelectorViewController alloc] initWithActualMonth:[self.easyIncomesAndExpensesQuery findActualSelectedMonth].month andInvalidInteractionMonths:nil];
    monthSelectorViewController.delegate = self;

    return monthSelectorViewController;
}

- (BOOL)isFavoritePinInteractionEnabledInConcepts
{
    //return [self.calculatorViewController isOpen] && [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
    return [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
}

- (void)executeLogicAfterFavoritePinTapForCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    const BOOL willFavoritePinBeEnabled = !cell.favoritePinEnabled;
    IAEConcept *conceptOfCell = [self.easyIncomesAndExpensesQuery findConceptOfCell:cell];
    if (willFavoritePinBeEnabled) {
        [[IAEFavoriteConceptsStock sharedInstance] addFavorite:conceptOfCell];
    } else {
        [[IAEFavoriteConceptsStock sharedInstance] removeFavoriteOfConcept:conceptOfCell];
    }
    [[IAEFavoriteConceptsStock sharedInstance] save];
    
    [self updateVisibleCollectionViewCellsEnabling:willFavoritePinBeEnabled
                                      withCategory:[conceptOfCell.category localizedTag]
                                          andValue:conceptOfCell.amount.stringValue];
}

- (CGPoint)convertLocationToCellArea:(UICollectionViewCell *)cell fromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [self extractConceptCollectionViewLocationFromGestureRecognizer:gestureRecognizer];
    CGPoint locationConvertedToCellArea = [cell convertPoint:location fromView:self.conceptsCollectionView];

    return locationConvertedToCellArea;
}

- (void)openPopoverForAdjustAmountOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    [cell setVisualAspectInEditMode:YES forConceptElement:EditModeConceptElement_Amount];

    IAEAdjustConceptAmountViewController *viewController = [[IAEAdjustConceptAmountViewController alloc] init];
    viewController.delegate = self;
    viewController.dataSource = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];

    [self createAndPresentPopoverForAdjustConceptCellView:[cell findAmountLabel] withViewController:viewController];
}

- (void)openPopoverForEditCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    [cell setVisualAspectInEditMode:YES forConceptElement:EditModeConceptElement_Category];

    IAECategory *categoryOfCell = [self.easyIncomesAndExpensesQuery findCategoryOfConceptCell:cell];
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc]
                                                         initWithExtraActions:CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION | CATEGORYSELECTOR_EXTRAACTION_ADD
                                                         withSelectedCategory:categoryOfCell];
    viewController.showNumberOfConcepts = NO;
    viewController.delegate = self;
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];

    self.categoriesSelectorViewController = viewController;
    
    [self createAndPresentPopoverForConceptCellView:[cell findCategoryLabel] withViewController:viewController];
}

- (void)createAndPresentPopoverForAdjustConceptCellView:(UILabel *)amountLabel withViewController:(UIViewController *)viewController
{
    CGFloat xMargin = kXMarginBaseForConceptCellPopover;
    CGSize textSize = [[amountLabel text] sizeWithAttributes:[amountLabel.attributedText attributesAtIndex:0 effectiveRange:NULL]];
    if (textSize.width > amountLabel.bounds.size.width) {
        textSize = CGSizeMake(amountLabel.bounds.size.width, textSize.height);
    }
    xMargin += textSize.width;
    
    CGRect translateViewFrameToGlobalCoordination = [amountLabel.superview convertRect:amountLabel.frame toView:amountLabel.superview];
    CGRect presentPopoverFrame = CGRectMake(translateViewFrameToGlobalCoordination.origin.x - xMargin + translateViewFrameToGlobalCoordination.size.width,
                                            translateViewFrameToGlobalCoordination.origin.y + kYMarginBaseForConceptCellPopover,
                                            translateViewFrameToGlobalCoordination.size.width,
                                            translateViewFrameToGlobalCoordination.size.height - kYMarginBaseForConceptCellPopover);
    
    [self presentPopoverForConceptCellView:amountLabel withViewController:viewController usingFrame:presentPopoverFrame andArrowDirection:UIPopoverArrowDirectionRight];
}

- (void)createAndPresentPopoverForConceptCellView:(UIView *)view withViewController:(UIViewController *)viewController
{
    CGRect translateViewFrameToGlobalCoordination = [view.superview convertRect:view.frame toView:view.superview];
    CGRect presentPopoverFrame = CGRectMake(translateViewFrameToGlobalCoordination.origin.x,
                                            translateViewFrameToGlobalCoordination.origin.y + kYMarginBaseForConceptCellPopover,
                                            translateViewFrameToGlobalCoordination.size.width,
                                            translateViewFrameToGlobalCoordination.size.height - kYMarginBaseForConceptCellPopover);
    
    UIPopoverArrowDirection arrowDirection = [self.calculatorViewController isInVisibleMode] ? UIPopoverArrowDirectionUp : UIPopoverArrowDirectionDown;
    
    [self presentPopoverForConceptCellView:view withViewController:viewController usingFrame:presentPopoverFrame andArrowDirection:arrowDirection];
}

- (void)presentPopoverForConceptCellView:(UIView *)view
                      withViewController:(UIViewController *)viewController
                              usingFrame:(CGRect)frame
                       andArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = viewController.view.bounds.size;
    [self.popover presentPopoverFromRect:frame
                                  inView:view.superview
                permittedArrowDirections:arrowDirection
                                animated:YES];
    
}

- (void)openPopoverForSelectDayOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    [cell setVisualAspectInEditMode:YES forConceptElement:EditModeConceptElement_DayOrNumberInstance];
    
    IAEOpenYear *year = [self.easyIncomesAndExpensesQuery findOpenYear];
    IAEMonth *month = [self.easyIncomesAndExpensesQuery findActualSelectedMonth];
    NSUInteger selectedDay = [self.easyIncomesAndExpensesQuery findDayOfTheMonthForConceptCell:cell];
    
    IAEDayCalendarSelectorViewController *viewController = [[IAEDayCalendarSelectorViewController alloc] initWithYearDate:year.yearDate
                                                                                                               monthIndex:month.month
                                                                                                           andDaySelected:selectedDay];
    viewController.conceptCellIndexPath = [self.conceptsCollectionView indexPathForCell:cell];
    viewController.delegate = self;
    
    [self createAndPresentPopoverForConceptCellView:cell.identifierContainerView withViewController:viewController];
}

- (void)removeConceptAndUpdateBalancesOfCell:(UICollectionViewCell *)cell withAnimation:(BOOL)animation
{
    NSAssert(cell, @"");

    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptOfCell:cell];
    IAEMonth *month = [self.easyIncomesAndExpensesQuery findActualSelectedMonth];
    NSIndexPath *indexPathOfCell = [self.conceptsCollectionView indexPathForCell:cell];
    
    [month removeConcept:concept];
    [[IAEBook sharedBook] saveAll];
    
    [self.conceptsCollectionView performBatchUpdates:^{
        // En algunas ocasiones nos ha dado fallo en este punto porque indexPathOfCell era nil
        CLSLog(@"deleteItemsAtIndexPaths from removeConceptAndUpdateBalancesOfCell");
        NSAssert(indexPathOfCell, @"");
        [self.conceptsCollectionView deleteItemsAtIndexPaths:@[indexPathOfCell]];
    } completion:^(BOOL finished) {
        [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:YES];
    }];
}

#pragma mark - IAEAdjustConceptAmountViewControllerDelegate

- (void)adjustConceptsAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptsAmountViewController
          didPressedAdjustButtonWithAmount:(NSNumber *)amount
{
    CLSLog(@"%s", __FUNCTION__);

    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptAtIndexPath:adjustConceptsAmountViewController.conceptCellIndexPath];
    
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:adjustConceptsAmountViewController.conceptCellIndexPath];
    
    [self updateWithNewAbsoluteValueOfConcept:concept byAdding:amount];
    [self.helperConceptsCollectionViewDataSource configureEditModeConceptCell:cell withConceptAtIndexPath:adjustConceptsAmountViewController.conceptCellIndexPath];
    [[IAEBook sharedBook] saveAll];
}

- (void)updateWithNewAbsoluteValueOfConcept:(IAEConcept *)concept byAdding:(NSNumber *)amount
{
    NSDecimalNumber *newConceptValue = [self calculeNewConceptValueForConcept:concept byAdding:amount];
    NSAssert([concept canAddAmount:amount], @"");
    
    concept.amount = [newConceptValue decimalNumberByAbsoluteValue];
}

- (NSDecimalNumber *)calculeNewConceptValueForConcept:(IAEConcept *)concept byAdding:(NSNumber *)amount
{
    NSDecimalNumber *amountDecimalNumber = [NSDecimalNumber decimalNumberWithString:[amount stringValue]];
    NSDecimalNumber *conceptAmountWithSign = [concept amountWithSign];
    NSDecimalNumber *newConceptValue = [conceptAmountWithSign decimalNumberByAdding:amountDecimalNumber];

    return newConceptValue;
}

#pragma mark - IAEAdjustConceptAmountViewControllerDataSource

- (BOOL)canAdjustConceptAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptViewController addAmount:(NSNumber *)amount
{
    CLSLog(@"%s", __FUNCTION__);
    
    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptAtIndexPath:adjustConceptViewController.conceptCellIndexPath];
    const BOOL can = [concept canAddAmount:amount];
    
    return can;
}

#pragma mark - IAECategorySelectorViewControllerDelegate

- (void)doneButtonWasPressedInCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
{
    NSAssert([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [self dismissViewControllerAnimated:YES completion:^{
        self.categoriesSelectorViewController = nil;
    }];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
                     didSelectCategory:(IAECategory *)category
{
    if ([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self launchCategoryEditorViewControllerModalFromCategorySelectorViewController:categorySelectorViewController ToRenameCategory:category];
    } else if ([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromConcept]) {
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
    CLSLog(@"%s", __FUNCTION__);
    
    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptAtIndexPath:indexPath];
    if (concept.category != category) {
        CategoryType originalCategoryType = concept.category.categoryType;
        concept.category = category;
        
        [[IAEBook sharedBook] saveAll];

        IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:indexPath];
        [self.helperConceptsCollectionViewDataSource configureEditModeConceptCell:cell withConceptAtIndexPath:indexPath];

        if (originalCategoryType != concept.category.categoryType) {
            [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:YES];
        }
    }
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
            didSelectAddCategoryOfType:(CategoryType)categoryType
{
    if ([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self launchCategoryEditorViewControllerModalToAddCategoryFromCategorySelectorViewController:categorySelectorViewController
                                                                        andCategoryType:categoryType];
    } else if ([self isPopoverAssociatedToConceptBecauseACategorySelectorViewController]) {
        // En el caso de lanzar desde un concepto no queremos hacer dismiss del popover ya que sera pieza clave para saber que hacer al retornar
        // de crear la categoria
        [self dismissCategorySelectorPopoverAndlaunchCategoryEditorViewControllerAndPrepareInstanceToAddNewCategoryOfType:categoryType];
    }
}

- (BOOL)isPopoverAssociatedToConceptBecauseACategorySelectorViewController
{
    IAECategorySelectorViewController *categorySelector = (IAECategorySelectorViewController *)self.popover.contentViewController;
    const BOOL isPopoverAssociated = self.popover != NULL && categorySelector && categorySelector.conceptCellIndexPath;
    
    return isPopoverAssociated;
}

- (void)launchCategoryEditorViewControllerModalToAddCategoryFromCategorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController andCategoryType:(CategoryType)categoryType
{
    [self dismisPopover];
    
    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToAddCategoryOfType:categoryType];
    categoryEditorViewController.delegate = self;
    categoryEditorViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [categorySelectorViewController presentViewController:categoryEditorViewController animated:YES completion:nil];
}

- (void)dismissCategorySelectorPopoverAndlaunchCategoryEditorViewControllerAndPrepareInstanceToAddNewCategoryOfType:(CategoryType)categoryType
{
    [self dismisPopover];
    
    self.categoryRenaming = nil;
    
    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToAddCategoryOfType:categoryType];
    categoryEditorViewController.delegate = self;
    categoryEditorViewController.conceptCellIndexPath = self.categoriesSelectorViewController.conceptCellIndexPath;
    
    self.categoriesSelectorViewController = nil;
    
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
    const BOOL actualContextHaveCategoriesOfThisType = [self actualContextHaveConceptsOfCategory:category];
    NSString *tagOfCategory = [category.tag copy];
    const CategoryType categoryType = category.categoryType;
    [[IAEFavoriteConceptsStock sharedInstance] removeAndSaveFavoriteWithCategory:category.localizedTag];
    [[IAECategoryStore sharedCategoryStore] removeCategoryByTag:tagOfCategory];
    [[IAEBook sharedBook] saveAll];

    if (actualContextHaveCategoriesOfThisType) {
        [self reloadActiveModeAfterRemoveCategoryWithTag:tagOfCategory andType:categoryType];
    }
    
    NSAssert([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton], @"");
    [categorySelectorViewController reloadAfterRemoveCellWithCategoryTag:tagOfCategory];
}

- (BOOL)actualContextHaveConceptsOfCategory:(IAECategory *)category
{
    NSArray *categoriesOfActualContextView = [self.easyIncomesAndExpensesQuery findAllCategoriesForActualSelectedContext];
    const BOOL haveConcepts = [categoriesOfActualContextView indexOfObject:category] != NSNotFound;
    
    return haveConcepts;
}

- (void)reloadActiveModeAfterRemoveCategoryWithTag:(NSString *)tagOfCategory andType:(CategoryType)type
{
    if ([self.easyIncomesAndExpensesQuery isEditModeActive]) {
        CLSLog(@"reloadData from reloadActiveModeAfterRemoveCategoryWithTag - if ([self isEditModeActive])");
        [self reloadContentOfConceptsCollectionView];
    } else if ([self.easyIncomesAndExpensesQuery isReportModeActive]) {
        const BOOL reload = (self.reportMenuView.currentOptionIndexSelected == kReportMenuIndexOfExpensesOption && type == ExpenseCategory) ||
                            (self.reportMenuView.currentOptionIndexSelected == kReportMenuIndexOfIncomesOption && type == IncomeCategory);
        if (reload) {
            [self reloadContentOfConceptsReportViewWithAnimation:YES];
        }
    }
}

#pragma mark - IAECategoryEditorViewControllerDelegate

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
             didCancelRenameCategory:(IAECategory *)category
{
    if ([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateNewCategoryTag:(NSString *)categoryTag
                      ofCategoryType:(CategoryType)categoryType
{
    IAECategory *newCategory = [[IAECategoryStore sharedCategoryStore] createCategoryOfType:categoryType
                                                                                     andTag:categoryTag
                                                                       withValidityTagCheck:NO];
    if (!newCategory) {
        CLSLog(@"No se creo la categoría con tag %@", categoryTag);
        NSAssert(newCategory, @"");
    }
    [[IAEBook sharedBook] saveAll];
    
    [self returnFromCategoryEditorViewController:categoryEditorViewController atPositionOfCategory:newCategory];
}

- (void)returnFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
                          atPositionOfCategory:(IAECategory *)newCategory
{
    if ([self.easyIncomesAndExpensesQuery categorySelectorViewControllerWasLaunchedFromCategoryButton]) {
        [self returnToUpdatedCategorySelectorViewControllerFromCategoryEditorViewController:categoryEditorViewController
                                                                       atPositionOfCategory:newCategory];
    } else {
        [self returnToUpdatedEditModeViewControllerFromCategoryEditorViewController:categoryEditorViewController changingConceptToNewCategory:newCategory];
    }
}

- (void)returnToUpdatedEditModeViewControllerFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
                                                 changingConceptToNewCategory:(IAECategory *)newCategory
{
    [self changeCategoryOfConceptAtIndexPath:categoryEditorViewController.conceptCellIndexPath toCategory:newCategory];
    //[self reloadContentOfConceptsCollectionView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)returnToUpdatedCategorySelectorViewControllerFromCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
                                                                 atPositionOfCategory:(IAECategory *)newCategory
{
    IAECategorySelectorViewController *categorySelector = (IAECategorySelectorViewController *)categoryEditorViewController.presentingViewController;
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
    [categorySelector reloadData];
    
    [self reloadContentOfConceptsCollectionView];
    [categorySelector scrollToCategory:newCategory withAnimation:NO];
    [categorySelector doAttractAttentionAnimationAtPositionOfCategory:newCategory];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateRenameCategory:(IAECategory *)category
                             withTag:(NSString *)tag
{
    category.tag = tag;
    [[IAEBook sharedBook] saveAll];
    
    [self returnFromCategoryEditorViewController:categoryEditorViewController atPositionOfCategory:category];
}

#pragma mark - IAEYearSelectorViewControllerDelegate

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didLoadSelectedYearDate:(NSUInteger)yearDate
{
    [self.contextMenuView animateOptionAtIndex:0 withAnimationType:TextRawSelectorAnimation_DestroyWithGosthAndReload];
    [self reloadAllWithAnimation:YES];

    self.yearSelectorViewController = nil;
}

- (void)reloadAllWithAnimation:(BOOL)animation
{
    [self.contextMenuView reloadOptionsStringNames];
    [self reloadBalancesOfContextViewsAndAvailabilityOfSelectorContextSubmenuWithAnimation:animation];
    [self updateContentInformationOfActualModeWithAnimation:animation];
}

- (void)reloadBalancesOfContextViewsAndAvailabilityOfSelectorContextSubmenuWithAnimation:(BOOL)animation
{
    [self.selectorContextView enumerateContextViewsUsingBlock:^(NSUInteger index, IAEContextView *contextView) {
        if (animation) {
            [contextView reloadDataWithAnimationFromUsingZeroValue:NO];
        } else {
            [contextView reloadDataWithoutAnimation];
        }
    }];
}

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didCreateAndLoadSelectedYearDate:(NSUInteger)yearDate
{
    [self.contextMenuView animateOptionAtIndex:0 withAnimationType:TextRawSelectorAnimation_DestroyWithGosthAndReload];
    [self reloadAllWithAnimation:YES];
    [self goToTodayMonth];
}

- (void)closeButtonWasPressedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    [self returnFromYearSelectorToSameYear];
}

- (void)openYearSelectedWasSelectedInYearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController
{
    [self returnFromYearSelectorToSameYear];
}

- (void)returnFromYearSelectorToSameYear
{
    if (self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate) {
        [self reloadAllWithAnimation:YES];
        self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate = NO;
    }
    
    self.yearSelectorViewController = nil;
}

- (void)yearSelectorViewController:(IAEYearSelectorViewController *)yearSelectorViewController didCleanOpenYearDate:(NSUInteger)yearDate
{
    // Nota: Este evento informa de que se ha vaciado el año abierto pero que aun no se ha cerrado el dialogo selector, es decir, la recarga
    // de datos sucedera si y solo si, se retorna al mismo año abierto antes de abrir la venta de seleccion de años
    self.reloadAllPendingFromYearSelectorIfReturnWithSameYearDate = YES;
}

- (BOOL)isOpenYearEqualToYearDate:(NSUInteger)yearDate
{
    return yearDate == [self.easyIncomesAndExpensesQuery findOpenYear].yearDate;
}

#pragma mark - Notification Center

- (void)notificationCenterOnDayModeOn:(NSNotification *)notification
{
    [self reloadContentOfConceptsCollectionView];
}

- (void)notificationCenterOnDayModeOff:(NSNotification *)notification
{
    [self reloadContentOfConceptsCollectionView];
}

- (void)notificationCenterInitialMonthChanged:(NSNotification *)notification
{
    NSNumber *newMonth = [[notification userInfo] objectForKey:@"newInitialMonth"];
    [self recalculeVisibleMonthsInOpenYearWithInitialMonth:(MonthType)(newMonth.integerValue)];
    [self.contextMenuView reloadOptionsStringNames];
    [self goToTodayMonth];
}

- (void)notificationCenterMainNavitationTitleTouched:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] isProVersionDisabled]) {
        if ([[IAEInAppPurchasesStore defaultStore] isInAppPurchasesAccesible]) {
            if ([IAEInternet isConnected]) {
                [self lauchInAppPurchaseStoreViewController];
            } else {
                [self launchAlertViewAboutInetConexionNotAvailable];
            }
        } else {
            [self launchAlertViewAboutInAppPurchasesInaccesible];
        }
    }
    
}

- (void)lauchInAppPurchaseStoreViewController
{
    UIViewController *modalViewController = [[IAEInAppPurchaseStoreViewController alloc] initWithNibName:nil bundle:nil];
    modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (void)launchAlertViewAboutInAppPurchasesInaccesible
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_INAPPPURCHASESINACCESIBLE_ALERTVIEW_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_INAPPPURCHASESINACCESIBLE_ALERTVIEW_MESSAGE", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_INAPPPURCHASESINACCESIBLE_ALERTVIEW_CANCEL", @"")
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)launchAlertViewAboutInetConexionNotAvailable
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_INETCONEXION_ALERTVIEW_TITLE", @"")
                                                        message:NSLocalizedString(@"LTEXT_INETCONEXION_ALERTVIEW_MESSAGE", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_INETCONEXION_ALERTVIEW_CANCEL", @"")
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (void)recalculeVisibleMonthsInOpenYearWithInitialMonth:(MonthType)initialMonth
{
    IAEOpenYear *openYear = [self.easyIncomesAndExpensesQuery findOpenYear];
    [openYear recalculeVisibleMonthsWithStartMonth:initialMonth];
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
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)notificationCenterKeyboardResignFromEditingConceptsNotes:(NSNotification *)notification
{
    if ([self.easyIncomesAndExpensesQuery isNoteModeActiveInConcepts] && self.noteModeWasActivatedWithoutCalculator) {
        [self.calculatorViewController hide];
        [self updateVisibleConceptsCollectionViewCellsChangeToDataMode];
        self.noteModeWasActivatedWithoutCalculator = NO;
    }
}

- (void)notificationCenterKeyboardSignForEditingConceptsNotes:(NSNotification *)notification
{
    // Añadimos un delay para que al teclado le de tiempo a coger ventaja y no haya un cuello de botella con la animacion
    // de desplazamiento del area de conceptos
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([self.easyIncomesAndExpensesQuery isCalculatorInHideMode]) {
            self.noteModeWasActivatedWithoutCalculator = YES;
            [self.calculatorViewController incomeButtonPressed:self];
        } else {
            
        }
    });
}

- (void)notificationCenterEndEditingNoteForModeConceptCollectionViewCell:(NSNotification *)notification
{
    IAEEditModeConceptCollectionViewCell *cell = notification.object;
    if (cell) {
        IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptOfCell:cell];
        NSString *noteForConcept = notification.userInfo[@"note"];
        if (![concept.detailDescription isEqualToString:noteForConcept]) {
            concept.detailDescription = noteForConcept;
            [[IAEBook sharedBook] saveAll];
        }
    }
}

#pragma mark - IAEDayCalendarSelectorViewControllerDelegate

- (void)dayCalendarSelectorViewController:(IAEDayCalendarSelectorViewController *)dayCalendarSelectorViewController
                             didSelectDay:(NSUInteger)day
{
    CLSLog(@"%s", __FUNCTION__);
    
    [self dismisPopover];

    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptAtIndexPath:dayCalendarSelectorViewController.conceptCellIndexPath];
    if (concept.dayOfTheMonth != day) {

        concept.dayOfTheMonth = day;
        [[IAEBook sharedBook] saveAll];

        NSArray *concepts = [self.easyIncomesAndExpensesQuery isDayModeActiveForConcepts] ? [concept.month allConceptsSortedByDay] : [concept.month allConceptsSortedByEntryInstant];
        NSUInteger newIndexOfConcept = [concepts indexOfObject:concept];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndexOfConcept inSection:0];
        [self.conceptsCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        [self.conceptsCollectionView performBatchUpdates:^{
            [self.conceptsCollectionView moveItemAtIndexPath:dayCalendarSelectorViewController.conceptCellIndexPath toIndexPath:newIndexPath];
        } completion:^(BOOL finished) {
            [self.conceptsCollectionView reloadItemsAtIndexPaths:self.conceptsCollectionView.indexPathsForVisibleItems];
            IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:newIndexPath];
            [cell doCallForAttentionAnimation];
        }];
    }
}

#pragma mark - IAECalculatorViewControllerDelegate

- (void)showFavoritesButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
}

- (void)setNavigationButtonsEnabled:(BOOL)enabled
{
    self.yearsButton.enabled = enabled;
    self.categoriesButton.enabled = enabled;
    self.favoritesButton.enabled = enabled;
}

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didRemoveFavoriteConceptWithCategory:(NSString *)category andValue:(NSString *)value
{
    [self updateVisibleCollectionViewCellsEnabling:NO withCategory:category andValue:value];
}

- (void)updateVisibleCollectionViewCellsEnabling:(BOOL)enabling withCategory:(NSString *)category andValue:(NSString *)value
{
    NSArray *visibleCells = self.conceptsCollectionView.visibleCells;
    for (IAEEditModeConceptCollectionViewCell *cell in visibleCells) {
        NSIndexPath *indexPathForCell = [self.conceptsCollectionView indexPathForCell:cell];
        IAEConcept *conceptOfCell = [self.easyIncomesAndExpensesQuery findConceptAtIndexPath:indexPathForCell];
        if ([[conceptOfCell.category localizedTag] isEqualToString:category] && [[conceptOfCell.amount stringValue] isEqualToString:value]) {
            if (enabling) {
                [cell enableFavoritePin];
            } else {
                [cell disableFavoritePin];
            }
        }
    }
}

- (void)showButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self releaseLongPressureOnConceptsCollectionView];

    [self setNavigationButtonsEnabled:NO];
    
    self.attachBehaviorForContainerFX.anchorPoint = self.calculatorViewController.view.center;
    
    if ([[NSUserDefaults standardUserDefaults] isProVersionEnabled]) {
        for (IAEEditModeConceptCollectionViewCell *cell in self.conceptsCollectionView.visibleCells) {
            [cell showFavoritePin];
        }
    }
}

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController hideButtonWasPressedWithAnimation:(BOOL)animation
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:animation];

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

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcepts:(NSArray *)concepts
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES andExecuteAfterAnimationTheLogicBlock:^{
        NSArray *indexPathsOfNewConcepts = [self findIndexPathsOfNewCreatedConcepts:concepts withDaysActive:[self.easyIncomesAndExpensesQuery isDayModeActiveForConcepts]];
        [self.conceptsCollectionView performBatchUpdates:^{
            [self.conceptsCollectionView insertItemsAtIndexPaths:indexPathsOfNewConcepts];
        } completion:^(BOOL finished) {
            if (self.conceptsCollectionView.visibleCells.count > 0) {
                [self.conceptsCollectionView scrollToItemAtIndexPath:indexPathsOfNewConcepts[indexPathsOfNewConcepts.count - 1] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
            [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:NO];
            [self changeVisibleConceptsCollectionViewCellsToDataModeWithAnimationIfAppropiate:YES];
        }];
    }];
}

- (NSArray *)findIndexPathsOfNewCreatedConcepts:(NSArray *)newCreatedConcepts withDaysActive:(BOOL)daysActive
{
    IAEMonth *currentMonth = [self.easyIncomesAndExpensesQuery findActualSelectedMonth];
    NSArray *sortedConcepts = daysActive ? [currentMonth allConceptsSortedByDay] : [currentMonth allConceptsSortedByEntryInstant];
    
    NSMutableArray *indexPathOfConcepts = [NSMutableArray arrayWithCapacity:newCreatedConcepts.count];
    for (IAEConcept *concept in newCreatedConcepts) {
        const NSUInteger indexOfConcept = [sortedConcepts indexOfObject:concept];
        NSAssert(indexOfConcept != NSNotFound, @"");
        NSIndexPath *indexPathOfConcept = [NSIndexPath indexPathForItem:indexOfConcept inSection:0];
        [indexPathOfConcepts addObject:indexPathOfConcept];
    }
    
    return [NSArray arrayWithArray:indexPathOfConcepts];
}

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES andExecuteAfterAnimationTheLogicBlock:^{
        [self updateAfterNewConceptCreated:concept withCallForAttentionAnimation:NO];
        [self changeVisibleConceptsCollectionViewCellsToDataModeWithAnimationIfAppropiate:YES];
    }];
}

- (void)changeVisibleConceptsCollectionViewCellsToDataModeWithAnimationIfAppropiate:(BOOL)animation
{
    if ([self.easyIncomesAndExpensesQuery isNoteModeActiveInConcepts]) {
        [self changeVisibleConceptsCollectionViewCellsToDataModeWithAnimation:animation];
    }
}

- (void)updateAfterNewConceptCreated:(IAEConcept *)concept withCallForAttentionAnimation:(BOOL)callForAttentionAnimation
{
    [self reloadConceptsCollectionViewAfterCreateNewConcept:concept withCallForAttentionAnimation:callForAttentionAnimation];
    [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:NO];
}

- (void)reloadConceptsCollectionViewAfterCreateNewConcept:(IAEConcept *)concept withCallForAttentionAnimation:(BOOL)callForAttentionAnimation
{
    if ([self.easyIncomesAndExpensesQuery isDayModeActiveForConcepts]) {
        [self reloadConceptsCollectionViewWithDayModeAfterCreateNewConcept:concept withCallForAttentionAnimation:callForAttentionAnimation];
    } else {
        [self reloadConceptsCollectionViewWithoutDayModeAfterCreateNewConcept:concept withCallForAttentionAnimation:callForAttentionAnimation];
    }
}

- (void)reloadConceptsCollectionViewWithDayModeAfterCreateNewConcept:(IAEConcept *)concept withCallForAttentionAnimation:(BOOL)callForAttentionAnimation
{
    NSArray *concepts = [self.easyIncomesAndExpensesQuery allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:nil];
    const NSUInteger indexOfConcept = [concepts indexOfObject:concept];
    NSIndexPath *indexPathOfInsertion = [NSIndexPath indexPathForRow:indexOfConcept inSection:0];
    NSIndexPath *indexPathForScroll = nil;
    if (self.conceptsCollectionView.visibleCells.count > 0) {
        // Aproximamos el scroll pues la celda aun no se ha creado
         indexPathForScroll = [NSIndexPath indexPathForRow:MIN([self.conceptsCollectionView numberOfItemsInSection:0] - 1, indexOfConcept) inSection:0];
        [self.conceptsCollectionView scrollToItemAtIndexPath:indexPathForScroll atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    
    [self.conceptsCollectionView performBatchUpdates:^{
        [self.conceptsCollectionView insertItemsAtIndexPaths:@[indexPathOfInsertion]];
    } completion:^(BOOL finished) {
        // Hacemos el scroll exacto
        [self.conceptsCollectionView scrollToItemAtIndexPath:indexPathOfInsertion atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        [self reloadVisibleItemsofConceptCollectionViewExceptItemAtIndexPath:indexPathOfInsertion];

        if (callForAttentionAnimation) {
            [self doCallForAttentionAnimationAtConceptCollectionViewCellWithIndexPath:indexPathOfInsertion];
        }
    }];
}

- (void)reloadConceptsCollectionViewWithoutDayModeAfterCreateNewConcept:(IAEConcept *)concept withCallForAttentionAnimation:(BOOL)callForAttentionAnimation
{
    IAEMonth *month = [self.easyIncomesAndExpensesQuery findActualSelectedMonth];
    NSAssert(month, @"");
    NSUInteger indexOfConcept = [[month allConceptsSortedByEntryInstant] indexOfObject:concept];
    NSAssert(indexOfConcept != NSNotFound, @"");
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexOfConcept inSection:0];
    if (self.conceptsCollectionView.visibleCells.count > 0) {
        [self.conceptsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    
    [self.conceptsCollectionView performBatchUpdates:^{
        [self.conceptsCollectionView insertItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        if (callForAttentionAnimation) {
            [self doCallForAttentionAnimationAtConceptCollectionViewCellWithIndexPath:indexPath];
        }
        
        [self reloadVisibleItemsofConceptCollectionViewExceptItemAtIndexPath:indexPath];
    }];
}

- (void)doCallForAttentionAnimationAtConceptCollectionViewCellWithIndexPath:(NSIndexPath *)indexPath
{
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell *)[self.conceptsCollectionView cellForItemAtIndexPath:indexPath];
    [cell doCallForAttentionAnimation];
}

- (void)reloadVisibleItemsofConceptCollectionViewExceptItemAtIndexPath:(NSIndexPath *)exceptItemIndexPath
{
    NSMutableArray *visibleItemsMinusNewConcept = [NSMutableArray arrayWithArray:self.conceptsCollectionView.indexPathsForVisibleItems];
    [visibleItemsMinusNewConcept removeObject:exceptItemIndexPath];
    [self.conceptsCollectionView reloadItemsAtIndexPaths:visibleItemsMinusNewConcept];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.conceptsCollectionView) {
        [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    }
}

- (void)hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:(BOOL)animation
{
    for (IAEEditModeConceptCollectionViewCell *cell in self.conceptsCollectionView.visibleCells) {
        [cell scrollToNormalModeUsingAnimation:animation];
    }
}

#pragma mark - IAEContextMenuActionSheetViewControllerDelegate

- (void)contextMenuActionSheetViewController:(IAEContextMenuActionSheetViewController *)contextMenuActionSheetViewController didSelectOption:(IAEContextMenuActionSheetOption)option;
{
    if (option == IAEContextMenuActionSheetOptionCSVExport) {
        [self exportAllConceptsOfActualSelectionContextViewToCSVIfApplicable];
    } else if (option == IAEContextMenuActionSheetOptionRemoveAllConcepts) {
        [self lauchAlertViewToConfirmRemoveAllConceptsInActualContext];
    }
    
    [self dismisPopover];
}

- (void)lauchAlertViewToConfirmRemoveAllConceptsInActualContext
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_TITLE", @"")
                                                        message:[self.easyIncomesAndExpensesQuery isActualSelectedContextAMonth] ? NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_MSG_MONTH", @"") : NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_MSG_YEAR", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_CANCELOPTION", @"")
                                              otherButtonTitles:NSLocalizedString(@"LTEXT_CONTEXTSUBMENU_ALERTVIEWREMOVEALLCONCEPTS_REMOVEOPTION", @""), nil];
    [alertView show];
    
    self.waitingToConfirmRemoveAllConcepts = YES;
}

- (void)deleteAllConceptsOfActualSelectionContextViewAndUpdateUserInterface
{
    [self deleteAllConceptsInModelObjectOfActualSelectionContextView];
    [self reloadDataAndUpdateBalancesWithAnimationInConceptCollectionViewAfterRemoveAllConcepts];
}

- (void)deleteAllConceptsInModelObjectOfActualSelectionContextView
{
    id modelObject = [self.easyIncomesAndExpensesQuery findModelObjectOfActualSelectedContextView];
    [modelObject deleteAllConcepts];
    [[IAEBook sharedBook] saveAll];
}

- (void)reloadDataAndUpdateBalancesWithAnimationInConceptCollectionViewAfterRemoveAllConcepts
{
    [UIView animateWithDuration:kAnimationForReloadDataAfterRemoveAllConcepts animations:^{
        self.conceptsCollectionView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.conceptsCollectionView reloadData];
        if ([self.easyIncomesAndExpensesQuery isReportModeActive]) {
            [self reloadContentOfConceptsReportViewWithAnimation:YES];
        }
        [self updateBalancesAndAvailabilityOfSelectorContextSubmenuWithAnimation:YES];
        [self showWithoutConceptsWarningViewIfAppropriateWithAnimation:YES];
        [UIView animateWithDuration:0 animations:^{
            self.conceptsCollectionView.alpha = 1.0;
        }];
    }];
}

- (void)exportAllConceptsOfActualSelectionContextViewToCSVIfApplicable
{
    if ([MFMailComposeViewController canSendMail]) {
        if ([self.easyIncomesAndExpensesQuery isActualSelectedContextAMonth]) {
            NSString *attachmentNameDescriptor = [self makeAttachmentNameDescriptorWithYear:[[self.easyIncomesAndExpensesQuery findOpenYear] yearDateAsString] andMonth:[self.easyIncomesAndExpensesQuery findActualSelectedMonth].description];
            if ([[IAEExporter sharedExporter] exportFromActualOpenYearToTMPCSVFileMonth:[self.easyIncomesAndExpensesQuery findActualSelectedMonth].month]) {
                [self lauchMailComposerViewControllerForSendCSVExport:attachmentNameDescriptor];
            }
        } else if ([self.easyIncomesAndExpensesQuery isActualSelectedContextTheYearOpen]) {
            NSString *attachmentNameDescriptor = [self makeAttachmentNameDescriptorWithYear:[[self.easyIncomesAndExpensesQuery findOpenYear] yearDateAsString] andMonth:nil];
            if ([[IAEExporter sharedExporter] exporToTMPCSVFileYear:[[IAEBook sharedBook] findActualOpenYear].yearDate]) {
                [self lauchMailComposerViewControllerForSendCSVExport:attachmentNameDescriptor];
            }
        }
    } else {
        [self lauchAlertViewCantSendCSVEmail];
    }
}

- (NSString *)makeAttachmentNameDescriptorWithYear:(NSString *)year andMonth:(NSString *)month
{
    NSString *attachmentNameDescriptor = [year stringByAppendingString:@"_"];
    if (month) {
        attachmentNameDescriptor = [[attachmentNameDescriptor stringByAppendingString:month] stringByAppendingString:@"_"];
    }
    attachmentNameDescriptor = [attachmentNameDescriptor stringByAppendingString:@"_EasyIncomesAndExpenses.csv"];
    
    return attachmentNameDescriptor;

}

- (void)lauchAlertViewCantSendCSVEmail
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_ALERT_CANTSENDEMAIL_ALERTVIEW_CSV_TITLE", @"") message:NSLocalizedString(@"LTEXT_ALERT_CANTSENDEMAIL_ALERTVIEW_CSV_MESSAGE", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"LTEXT_ALERT_CANTSENDEMAIL_ALERTVIEW_CSV_OKBUTTON", @"") otherButtonTitles:nil];
    [alertView show];
}

- (void)lauchMailComposerViewControllerForSendCSVExport:(NSString *)attachmentNameDescriptor
{
    MFMailComposeViewController *appEmailViewController = [[MFMailComposeViewController alloc] init];
    appEmailViewController.mailComposeDelegate = self;
    
    [appEmailViewController setSubject:NSLocalizedString(@"LTEXT_EMAIL_SUBJECTCSVEXPORT", @"")];
    
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[IAEExporter exportCSVFileNameWithExtension]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:pathForTMPDirectory];
    const BOOL fileHandleOk = fileHandle != nil;
    if (fileHandleOk) {
        NSData *fileData = [fileHandle readDataToEndOfFile];
        [appEmailViewController addAttachmentData:fileData mimeType:@"text/csv" fileName:attachmentNameDescriptor];
        [self presentViewController:appEmailViewController animated:YES completion:nil];
    } else {
        [appEmailViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IAETextRawSelectorMenuViewDelegate

- (BOOL)canSelectOptionIndex:(NSUInteger)optionIndex inTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenuView
{
    BOOL canSelect = YES;
    
    if (self.conceptCellToRemove) {
        canSelect = NO;
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenuView]) {
        canSelect = ![self.reportAreaView existChangeTitleInProgressOnReportAreaItems];
    }
    
    return canSelect;
}

- (void)optionIndex:(NSUInteger)optionIndex wasSelectedInTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenuView
{
    if ([self isTheContextMenuTheTextRawSelectorMenuView:textRawSelectorMenuView]) {
        if ([self isChangeOfContextRunning]) {
            self.lastContextIndexMenuPressed = optionIndex;
        } else {
            [self gotoToContextViewWithIndex:optionIndex];
        }
    } else if ([self isTheReportMenuTheTextRawSelectorMenuView:textRawSelectorMenuView]) {
        [self reloadContentOfConceptsReportViewWithAnimation:YES];
    }
}

- (void)optionIndex:(NSUInteger)optionIndex wasReSelectedInTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenuView
{
    [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
    [self lauchContextMenuActionSheetForContextMenuAtOptionIndexIfApplicable:optionIndex];
}

- (void)lauchContextMenuActionSheetForContextMenuAtOptionIndexIfApplicable:(NSUInteger)optionIndex
{
    if ([[NSUserDefaults standardUserDefaults] isProVersionEnabled]) {
        self.contextMenuActionSheetViewController = [[IAEContextMenuActionSheetViewController alloc] initWithEnabledOption:[self.easyIncomesAndExpensesQuery existConceptsInActualSelectedContext] ? IAEContextMenuActionSheetOptionAll : IAEContextMenuActionSheetOptionOptionsNone];
        self.contextMenuActionSheetViewController.delegate = self;
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.contextMenuActionSheetViewController];
        self.popover.delegate = self;
        self.popover.popoverContentSize = self.contextMenuActionSheetViewController.view.bounds.size;
        [self.popover presentPopoverFromRect:CGRectOffset([self.contextMenuView rectOfOptionAtIndex:optionIndex], 0, 4)
                                      inView:self.contextMenuView
                    permittedArrowDirections:UIPopoverArrowDirectionUp
                                    animated:YES];
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

#pragma mark - IAEFavoriteConceptsViewControllerDelegate

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
didPressedAddOptionWithFavoriteIncomes:(NSArray *)incomes
                           andExpenses:(NSArray *)expenses
{
    // ...
}

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
        willRemoveFavoriteWithCategory:(NSString *)category
                              andValue:(NSString *)value
{
    // ...
}

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
         didRemoveFavoriteWithCategory:(NSString *)category
                              andValue:(NSString *)value
{
    [self updateVisibleCollectionViewCellsEnabling:NO withCategory:category andValue:value];
}

- (void)doneButtonWasPressedInfavoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController;
{
     // ...
}

#pragma mark - IAEMonthSelectorViewControllerDelegate

- (void)monthSelectorViewController:(IAEMonthSelectorViewController *)monthSelectorViewController didSelectMonth:(MonthType)month
{
    [self dismisPopover];
    [self executeActionOnMonth:[[[IAEBook sharedBook] findActualOpenYear] findMonthObjectOfMonthDate:month]
                basedInPurpose:self.monthSelectorPurpose
                   withConceptOfCell:[self.easyIncomesAndExpensesQuery findConceptCollectionCellWithMenuModeActive]];
}

- (void)executeActionOnMonth:(IAEMonth *)month basedInPurpose:(MonthSelectorPurpose)purpose withConceptOfCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self.easyIncomesAndExpensesQuery findConceptOfCell:cell];
    [month duplicateConcept:concept];
    if (purpose == MonthSelectorPurposeCopy) {
        [self hideMenuModeActiveInAllConceptsCollectionCellUsingAnimation:YES];
        [self.contextMenuView animateOptionAtIndex:month.month withAnimationType:TextRawSelectorAnimation_Blink];
    } else if (purpose == MonthSelectorPurposeMove) {
        self.conceptCellToRemove = cell;
        [self removeConceptAndUpdateBalancesOfCell:cell withAnimation:YES];
        [self.contextMenuView animateOptionAtIndex:month.month withAnimationType:TextRawSelectorAnimation_Blink];
    }
}

#pragma mark - Actions

- (void)resetToLaunchState
{
    [self.conceptsCollectionView reloadData];
    [self.calculatorViewController hideWithoutAnimation];
    [self configureNavigationBar];
    [self reloadMainNavigationTitle];
}

- (void)reloadMainNavigationTitle
{
    IAEMainNavigationTitle *navigationTitle = (IAEMainNavigationTitle *)self.navigationItem.titleView;
    [navigationTitle reloadTitle];
}

@end
