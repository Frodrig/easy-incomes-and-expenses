//
//  IAECategorySelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategorySelectorViewController.h"
#import "IAECategoryStore.h"
#import "IAECategoryTableViewCell.h"
#import "IAECategory.h"
#import "IAECategoryStore.h"
#import "IAEBook.h"
#import "IAECategorySelectorViewControllerDelegate.h"
#import "IAECircleDecoratorView.h"
#import "IAEStrokeAnimatableLineView.h"
#import "IAELocalizerPhraseComposer.h"

@interface IAECategorySelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, weak) IAECategory *categoryOfCellSelectedToRemove;
@property (nonatomic) NSUInteger actions;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationToolBar;
@property (nonatomic, weak) IAECategory* initialCategory;
@property (nonatomic, strong) NSIndexPath *selectedCategoryIndexPath;
@property (nonatomic) CategoryType selectedCategoryType;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableView;

@end

@implementation IAECategorySelectorViewController

static const NSUInteger kIncomeSegmentedIndex = 0;
static const NSUInteger kExpenseSegmentedIndex = 1;

static NSString * const kLTextIncomeCategoryTitleOption = @"LTEXT_CATEGORYSELECTOR_INCOMESOPTION";
static NSString * const kLTextExpenseCategoryTitleOption = @"LTEXT_CATEGORYSELECTOR_EXPENSESOPTION";
static NSString * const kXibOfCategoryTableViewCellWithoutNumberOfConcepts = @"IAECategoryTableViewCell";
static NSString * const kXibOfCategoryTableViewCellWithNumberOfConcepts = @"IAECategoryWithNumberOfConceptsTableView";
static NSString * const kIDOfCategoryTableViewCell = @"CategoryTableViewCell";

static NSString * const kFontOfGeneralCategoryLabel = @"HelveticaNeue-UltraLightitalic";
static NSString * const kFontOfUserCategoryLabel = @"HelveticaNeue-UltraLight";
static const CGFloat kSizeOfCategoryNameLabel = 28;
static const CGFloat kHeightOfCategoriesWithoutNumberOfConceptsCell = 51;
static const CGFloat kHeightOfCategoriesWithNumberOfConceptsCell = 78;

static const CGFloat kDurationOfAnimationOfOpenDecoratorView = 0.1;

static const NSUInteger kButtonIndexOfRemoveConfirmationAlertView = 1;

static const CGFloat kDurationStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimation = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimation = 1.0;
static const NSInteger kTypeStrokeAnimation = STROKEANIMATABLE_TYPE_THIN;

#pragma mark - Properties

- (IAEStrokeAnimatableLineView *)strokeAnimatableView
{
    if (nil == _strokeAnimatableView) {
        _strokeAnimatableView = [[IAEStrokeAnimatableLineView alloc] init];
        _strokeAnimatableView.durationOfStrokeAnimation = kDurationStrokeAnimation;
        _strokeAnimatableView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimation
                                                              alpha:kColorWhiteAlphaComponentForStrokeAnimation];
        _strokeAnimatableView.strokeType = kTypeStrokeAnimation;
        _strokeAnimatableView.delegate = self;
    }
    
    return _strokeAnimatableView;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"No deberia de instanciarse este init");
    self = nil;
    
    return self;
}

// Designated
- (id)initWithExtraActions:(NSUInteger)actions withSelectedCategory:(IAECategory *)category
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self initActions:actions];
        [self initSwipeGestureRecognizer];
        _initialCategory = category;
    }
    
    return self;
}

- (id)initWithAllExtraActionsWithSelectedCategory:(IAECategory *)category;
{
    self = [self initWithExtraActions:CATEGORYSELECTOR_EXTRAACTION_ALL_ACTIONS withSelectedCategory:category];
    if (self) {
        // ...
    }
    
    return self;
}

- (id)initWithAllExtraActionsExceptSelectionWithSelectedCategory:(IAECategory *)category
{
    NSUInteger categoryActions = CATEGORYSELECTOR_EXTRAACTION_ADD |
                                 CATEGORYSELECTOR_EXTRAACTION_DONE |
                                 CATEGORYSELECTOR_EXTRAACTION_DELETE;
    self = [self initWithExtraActions:categoryActions withSelectedCategory:category];
    if (self) {
        // ...
    }
    
    return self;
}

- (void)initActions:(NSUInteger)actions
{
    _actions = actions;
}

- (void)initSwipeGestureRecognizer
{
    if ([self deleteActionFlagEnabled]) {
        _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerEvent:)];
    }
}

- (void)dealloc
{
    [self.categoriesTableView removeGestureRecognizer:self.swipeGestureRecognizer];
}

#pragma mark - ViewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationItem];
    [self configureCategorySegmentedControl];
    [self configureCategoriesTableView];
}

- (void)configureNavigationItem
{
    if (![self addActionFlagEnabled]) {
        self.navigationToolBar.rightBarButtonItem = nil;
    }
    
    if (![self doneActionFlagEnabled]) {
        self.navigationToolBar.leftBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareWithInitialCategory];
}

- (void)prepareWithInitialCategory
{
    if (self.initialCategory) {
        [self changeToSectionOfCategoryType:self.initialCategory.categoryType];
        [self selectAndScrollToCategory:self.initialCategory withAnimation:NO];
        // Nota: Al seleccionarse manualmente la celda no se ejecuta el delegado y hay que llamar manualmente a changeToNewSelectedIndexPath:
        [self changeToSelectedIndexPath:[self findIndexPathOfCategory:self.initialCategory]
                         ofCategoryType:self.initialCategory.categoryType
                          withAnimation:NO
                andLogicBlockWhenFinish:nil];
        self.initialCategory = nil;
    } else {
        [self changeToSectionOfCategoryType:IncomeCategory];
    }
}

- (BOOL)categorySelectionFlagEnabled
{
    return [self isCategorySelectionWithDecoratorFlagEnabled] || [self isCategorySelectionWithoutDecoratorFlagEnabled];
}

- (BOOL)isCategorySelectionWithDecoratorFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION;
}

- (BOOL)isCategorySelectionWithoutDecoratorFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTIONWITHOUTDECORATOR;
}

- (BOOL)addActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_ADD;
}

- (BOOL)doneActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_DONE;
}

- (BOOL)deleteActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_DELETE;
}

- (void)configureCategorySegmentedControl
{
    [self.categorySegmentedControl setTitle:NSLocalizedString(kLTextIncomeCategoryTitleOption, @"") forSegmentAtIndex:kIncomeSegmentedIndex];
    [self.categorySegmentedControl setTitle:NSLocalizedString(kLTextExpenseCategoryTitleOption, @"") forSegmentAtIndex:kExpenseSegmentedIndex];
}

- (void)configureCategoriesTableView
{
    NSString *xibName = [self xibNameBasedInShowNumberOfConcepts];
    [self.categoriesTableView registerNib:[UINib nibWithNibName:xibName bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:kIDOfCategoryTableViewCell];
    self.categoriesTableView.allowsSelection = [self categorySelectionFlagEnabled];
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    
    if (self.swipeGestureRecognizer) {
        [self.categoriesTableView addGestureRecognizer:self.swipeGestureRecognizer];
    }
}

- (NSString *)xibNameBasedInShowNumberOfConcepts
{
    return self.showNumberOfConcepts ? kXibOfCategoryTableViewCellWithNumberOfConcepts : kXibOfCategoryTableViewCellWithoutNumberOfConcepts;
}

- (void)reloadData
{
    [self.categoriesTableView reloadData];
}

- (void)reloadAfterRemoveCellWithCategoryTag:(NSString *)categoryTag
{
    IAECategoryTableViewCell *cell = [self findVisibleCellOfCategoryWithTag:categoryTag];
    NSIndexPath *indexPathOfCell = [self.categoriesTableView indexPathForCell:cell];
    [self.categoriesTableView deleteRowsAtIndexPaths:@[indexPathOfCell] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)changeToSectionOfCategoryType:(CategoryType)category
{
    CategoryType actualCategory = [self categoryTypeSelectedInCategorySegmentedControl];
    if (actualCategory != category) {
        NSAssert(category != InvalidCategory, @"");
        self.categorySegmentedControl.selectedSegmentIndex = [self segmentedIndexForCategoryType:category];
        
        [self reloadData];
    }
}

- (NSInteger)segmentedIndexForCategoryType:(CategoryType)category
{
    NSInteger segmentedIndex = category == IncomeCategory ? kIncomeSegmentedIndex : kExpenseSegmentedIndex;
    
    return segmentedIndex;
}

- (void)selectAndScrollToCategory:(IAECategory *)category withAnimation:(BOOL)animation
{
    NSIndexPath *indexPathOfCategory = [self findIndexPathOfCategory:category];
    [self changeToSelectedIndexPath:indexPathOfCategory ofCategoryType:category.categoryType withAnimation:animation andLogicBlockWhenFinish:nil];
    [self.categoriesTableView selectRowAtIndexPath:indexPathOfCategory animated:animation scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)changeToSelectedIndexPath:(NSIndexPath *)newSelectedIndexPath
                   ofCategoryType:(CategoryType)categoryType
                    withAnimation:(BOOL)animation
          andLogicBlockWhenFinish:(void(^)(void))logicBlock
{
    if ([self isCategorySelectionWithoutDecoratorFlagEnabled]) {
        self.selectedCategoryIndexPath = newSelectedIndexPath;
        self.selectedCategoryType = categoryType;
        if (logicBlock) {
            logicBlock();
        }
    } else {
        void(^animationCoordinationBlock)(void) = ^(void) {
            self.selectedCategoryIndexPath = newSelectedIndexPath;
            self.selectedCategoryType = categoryType;
            [self makeOpenDecoratorViewAtIndexPath:self.selectedCategoryIndexPath
                                           visible:YES
                                     withAnimation:animation
                                     andLogicBlock:logicBlock];
                
        };
        
        [self makeOpenDecoratorViewAtIndexPath:self.selectedCategoryIndexPath
                                       visible:NO
                                 withAnimation:animation
                                 andLogicBlock:animationCoordinationBlock];
    }
}

- (void)makeOpenDecoratorViewAtIndexPath:(NSIndexPath *)indexPath
                                 visible:(BOOL)visible
                           withAnimation:(BOOL)animation
                           andLogicBlock:(void(^)(void))logicBlock
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView cellForRowAtIndexPath:indexPath];
    cell.openDecoratorView.alpha = visible ? 0.0 : 1.0;
    cell.openDecoratorView.hidden = NO;
    [UIView animateWithDuration:animation ? kDurationOfAnimationOfOpenDecoratorView : 0 animations:^{
        cell.openDecoratorView.alpha = visible ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        cell.openDecoratorView.hidden = !visible;
        cell.openDecoratorView.alpha = 1.0;
        if (logicBlock) {
            logicBlock();
        }
    }];
}

- (NSIndexPath *)findIndexPathOfCategory:(IAECategory *)category
{
    NSArray *categories = [self findCategoriesOfSelectedCategoryType];
    NSUInteger indexOfCategory = [categories indexOfObject:category];
    NSIndexPath *indexPathOfCategory = indexOfCategory != NSNotFound ? [NSIndexPath indexPathForRow:indexOfCategory inSection:0]: nil;
    
    return indexPathOfCategory;
}

#pragma mark - Control Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self.delegate doneButtonWasPressedInCategorySelectorViewController:self];
}

- (IBAction)addCategoryButtonPressed:(id)sender
{
    CategoryType actualCategoryType = [self categoryTypeSelectedInCategorySegmentedControl];
    [self.delegate categorySelectorViewController:self didSelectAddCategoryOfType:actualCategoryType];
}

- (IBAction)categorySegmentedControlPressed:(id)sender
{
    [self.categoriesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self changeToSelectedIndexPath:indexPath ofCategoryType:self.selectedCategoryType withAnimation:YES andLogicBlockWhenFinish:^{
        [self.delegate categorySelectorViewController:self didSelectCategory:[self findCategoryOfCellAtIndexPath:indexPath]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.showNumberOfConcepts ? kHeightOfCategoriesWithNumberOfConceptsCell : kHeightOfCategoriesWithoutNumberOfConceptsCell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAECategoryTableViewCell *categoryTableViewCell = (IAECategoryTableViewCell *)cell;
    [categoryTableViewCell exitOfStrokeStateWithAnimation:NO];
    [self.strokeAnimatableView resetStroke];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"
                                                                                                                forIndexPath:indexPath];
    IAECategory *category = [self findCategoryOfCellAtIndexPath:indexPath];
    [self configureTableViewCell:cell atIndexPath:(NSIndexPath *)indexPath withCategory:category];
    
    return cell;
}

- (IAECategory *)findCategoryOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *categories = [self findCategoriesOfSelectedCategoryType];
    IAECategory *category = [categories objectAtIndex:indexPath.row];
    
    return category;
}

- (NSArray *)findCategoriesOfSelectedCategoryType
{
    CategoryType categoryTypeSelected = [self categoryTypeSelectedInCategorySegmentedControl];
    NSArray *categories = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryTypeSelected];
    
    return categories;
}

- (void)configureTableViewCell:(IAECategoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withCategory:(IAECategory *)category
{
    NSDictionary *attributes = [self createAttributeDictionaryForCategoryNameAttributeTextWithCategory:category];
    cell.categoryLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag]
                                                                        attributes:attributes];
    if (self.showNumberOfConcepts) {
        NSUInteger numberOfConceptsOfCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category].count;
        cell.numberOfConceptsLabel.text = [IAELocalizerPhraseComposer stringPhraseWithNumberOfConcepts:numberOfConceptsOfCategory];
    }
    
    const BOOL selectedCategory = self.selectedCategoryIndexPath ? [self.selectedCategoryIndexPath compare:indexPath] == NSOrderedSame && category.categoryType == self.selectedCategoryType : NO;
    cell.openDecoratorView.hidden = !selectedCategory;
}

- (NSDictionary *)createAttributeDictionaryForCategoryNameAttributeTextWithCategory:(IAECategory *)category
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForCategoryNameWithCategory:category],
                                  NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForCategoryNameWithCategory:(IAECategory *)category
{
    BOOL generalCategory = [[IAECategoryStore sharedCategoryStore] isGeneralCategory:category];
    return [UIFont fontWithName:generalCategory ? kFontOfGeneralCategoryLabel : kFontOfUserCategoryLabel size:kSizeOfCategoryNameLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CategoryType categoryTypeSelected = [self categoryTypeSelectedInCategorySegmentedControl];
    NSInteger retNumber = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryTypeSelected].count;
    
    return retNumber;
}

- (CategoryType)categoryTypeSelectedInCategorySegmentedControl
{
    CategoryType categoryType = IncomeCategory;
    if (self.categorySegmentedControl.selectedSegmentIndex == kExpenseSegmentedIndex) {
        categoryType = ExpenseCategory;
    }
    
    return categoryType;
}

#pragma mark - SwipeGestureRecognizer

- (void)swipeGestureRecognizerEvent:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    [self deleteIfAppropiateCategoryOfCellUnderLocation:[swipeGestureRecognizer locationInView:self.categoriesTableView]];
}

- (void)deleteIfAppropiateCategoryOfCellUnderLocation:(CGPoint)location
{
    IAECategoryTableViewCell *cell = [self findCellUnderLocation:location];
    IAECategory *category = [self findCategoryOfCell:cell];
    if (![[IAECategoryStore sharedCategoryStore] isGeneralCategory:category]) {
        self.categoryOfCellSelectedToRemove = category;
        [self.strokeAnimatableView doStrokeOverTheView:cell.containerForStrokeCategoryLabelView];
        [cell goToStrokeStateWithAnimation:YES];
    }
}

- (IAECategory *)findCategoryOfCellSelectedUnderLocation:(CGPoint)location
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self findCellUnderLocation:location];
    IAECategory *category = [self findCategoryOfCell:cell];

    return category;
}

- (IAECategoryTableViewCell *)findCellUnderLocation:(CGPoint)location
{
    NSIndexPath *cellIndexPath = [self.categoriesTableView indexPathForRowAtPoint:location];
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView cellForRowAtIndexPath:cellIndexPath];
    
    return cell;
}

- (IAECategory *)findCategoryOfCell:(IAECategoryTableViewCell *)cell
{
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:cell.categoryLabel.text];
    return category;
}

- (void)removeCategoryOfCellSelectedIfAppropiateLaunchingConfirmation
{
    BOOL categoryOfCellSelectedHaveConcepts = [[IAEBook sharedBook] findAllConceptsWithCategory:self.categoryOfCellSelectedToRemove].count > 0;
    if (categoryOfCellSelectedHaveConcepts) {
        [self launchAlertViewBeforeDeleteCategory];
    } else {
        [self sendRemoveCategoryOfCellSelectedActionExecuted];
    }
}

- (void)launchAlertViewBeforeDeleteCategory
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_TITLE", @"")
                              message:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_MESSAGE", @"")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_CANCELOPTION", @"")
                              otherButtonTitles:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_REMOVEOPTION", @""), nil];
    
    [alertView show];
}

- (void)sendRemoveCategoryOfCellSelectedActionExecuted
{
    NSAssert(self.categoryOfCellSelectedToRemove, @"");
    [self.delegate categorySelectorViewController:self didSelectRemoveCategory:self.categoryOfCellSelectedToRemove];
    self.categoryOfCellSelectedToRemove = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kButtonIndexOfRemoveConfirmationAlertView) {
        [self sendRemoveCategoryOfCellSelectedActionExecuted];
    } else {
        [self exitOfStrokeStateInCellOfSelectedCategory];
    }
}

- (void)exitOfStrokeStateInCellOfSelectedCategory
{
    IAECategoryTableViewCell *cell = [self findCellOfCategorySelected];
    [cell exitOfStrokeStateWithAnimation:YES];
    [self.strokeAnimatableView resetStroke];
}

- (IAECategoryTableViewCell *)findCellOfCategorySelected
{
    IAECategoryTableViewCell *cellOfCategorySelected = [self findVisibleCellOfCategoryWithTag:self.categoryOfCellSelectedToRemove.tag];
    
    return cellOfCategorySelected;
}

- (IAECategoryTableViewCell *)findVisibleCellOfCategoryWithTag:(NSString *)categoryTag
{
    IAECategoryTableViewCell *retCell = nil;
    for (IAECategoryTableViewCell *cell in self.categoriesTableView.visibleCells) {
        if ([categoryTag isEqualToString:cell.categoryLabel.text]) {
            retCell = cell;
            break;
        }
    }
    
    return retCell;
}

#pragma mark - IAEStrokeAnimatableViewDelegate

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view
{
    [self removeCategoryOfCellSelectedIfAppropiateLaunchingConfirmation];
}

@end
