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
#import "IAEColorHelper.h"
#import <CoreText/CoreText.h>

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
@property (nonatomic, strong) NSDictionary *labelAttributesForGeneralCategory;
@property (nonatomic, strong) NSDictionary *labelAttributesForUserCategory;

@end

@implementation IAECategorySelectorViewController

static const NSUInteger kIncomeSegmentedIndex = 0;
static const NSUInteger kExpenseSegmentedIndex = 1;

static NSString * const kLTextIncomeCategoryTitleOption = @"LTEXT_CATEGORYSELECTOR_INCOMESOPTION";
static NSString * const kLTextExpenseCategoryTitleOption = @"LTEXT_CATEGORYSELECTOR_EXPENSESOPTION";
static NSString * const kXibOfCategoryTableViewCellWithoutNumberOfConcepts = @"IAECategoryTableViewCell";
static NSString * const kXibOfCategoryTableViewCellWithNumberOfConcepts = @"IAECategoryWithNumberOfConceptsTableView";
static NSString * const kIDOfCategoryTableViewCell = @"CategoryTableViewCell";

static NSString * const kFontOfGeneralCategoryLabel = @"HelveticaNeue-Thin_Italic";
static NSString * const kFontOfUserCategoryLabel = @"HelveticaNeue-Thin";
static const CGFloat kSizeOfCategoryNameLabel = 21;
static const CGFloat kSmallSizeOfCategoryNameLabel = 21;
static const CGFloat kHeightOfCategoriesWithoutNumberOfConceptsCell = 44;
static const CGFloat kHeightOfCategoriesWithNumberOfConceptsCell = 78;

static const CGFloat kDurationOfAnimationOfOpenDecoratorView = 0.1;

static const CGFloat kDurationStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimation = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimation = 1.0;
static const NSInteger kTypeStrokeAnimation = STROKEANIMATABLE_TYPE_THIN;

static const CGFloat kDurationOfAttractAttentionAnimationFadeIn = 0.25;
static const CGFloat kDurationOfAttractAttentionAnimationFadeOut = 0.5;
static const CGFloat kColorWhiteValueForAttractAttentionFadeIn = 0.8;
static const CGFloat kAlphaOfColorWhiteValueForAttractAttentionFadeIn = 0.3;

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
        [self createAttributesForCategoryLabels];
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

- (void)createAttributesForCategoryLabels
{
    self.labelAttributesForGeneralCategory = [self createAttributeDictionaryForGeneralCategory];
    self.labelAttributesForUserCategory = [self createAttributeDictionaryForUserCategory];
}

- (NSDictionary *)createAttributeDictionaryForGeneralCategory
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForCategoryNameWithGeneralCategory],
                                  NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSKernAttributeName: @(0)};
    
    return attributes;
}

- (UIFont *)createFontForCategoryNameWithGeneralCategory
{
    // Bug introducido por Apple desde la version 7.1
    // Woraround: http://stackoverflow.com/questions/19527962/what-happened-to-helveticaneue-italic-on-ios-7-0-3
    UIFont *font = [UIFont fontWithName:kFontOfGeneralCategoryLabel size:kSizeOfCategoryNameLabel];
    if (!font) {
        font = [UIFont fontWithName:kFontOfUserCategoryLabel size:kSizeOfCategoryNameLabel];
    }
    
    return font;
}

- (NSDictionary *)createAttributeDictionaryForUserCategory
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForCategoryNameWithUserCategory],
                                  NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForCategoryNameWithUserCategory
{
    return [UIFont fontWithName:kFontOfUserCategoryLabel size:self.showNumberOfConcepts ? kSizeOfCategoryNameLabel : kSmallSizeOfCategoryNameLabel];
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
        
        if ([self isInitialCategorySelectedSameAsActualCategoryTypeSelected]) {
            [self makeOpenDecoratorViewAtIndexPath:self.selectedCategoryIndexPath
                                           visible:NO
                                     withAnimation:animation
                                     andLogicBlock:animationCoordinationBlock];
        } else {
            animationCoordinationBlock();
        }
    }
}

- (void)scrollToCategory:(IAECategory *)category withAnimation:(BOOL)animation
{
    NSIndexPath *indexPathOfCategory = [self findIndexPathOfCategory:category];
    [self.categoriesTableView scrollToRowAtIndexPath:indexPathOfCategory atScrollPosition:UITableViewScrollPositionMiddle animated:animation];
}

- (void)doAttractAttentionAnimationAtPositionOfCategory:(IAECategory *)category
{
    NSIndexPath *indexPathOfCategory = [self findIndexPathOfCategory:category];
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *) [self.categoriesTableView cellForRowAtIndexPath:indexPathOfCategory];
    [UIView animateWithDuration:kDurationOfAttractAttentionAnimationFadeIn animations:^{
        cell.backgroundColor = [UIColor colorWithWhite:kColorWhiteValueForAttractAttentionFadeIn alpha:kAlphaOfColorWhiteValueForAttractAttentionFadeIn];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kDurationOfAttractAttentionAnimationFadeOut animations:^{
            cell.backgroundColor = [UIColor clearColor];
        }];
    }];
}
     
- (BOOL)isIncomeCategoryTypeSelected
{
    const BOOL isSelected = self.categorySegmentedControl.selectedSegmentIndex == kIncomeSegmentedIndex;
    
    return isSelected;
}

- (BOOL)isExpenseCategoryTypeSelected
{
    const BOOL isSelected = self.categorySegmentedControl.selectedSegmentIndex == kExpenseSegmentedIndex;
    
    return isSelected;
}

- (BOOL)isInitialCategorySelectedSameAsActualCategoryTypeSelected
{
    CategoryType categoryTypeOfCategorySegmentedControl = [self categoryTypeOfCategorySegmentedControlSelectedIndex];
    const BOOL isSame = categoryTypeOfCategorySegmentedControl == self.initialCategory.categoryType;
    
    return isSame;
}

- (CategoryType)categoryTypeOfCategorySegmentedControlSelectedIndex
{
    CategoryType categoryType = IncomeCategory;
    if (self.categorySegmentedControl.selectedSegmentIndex == kExpenseSegmentedIndex) {
        categoryType = ExpenseCategory;
    }
    
    return categoryType;
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
    const BOOL completelyVisible = [self isCompletelyVisibleCellIndexPath:indexPath];
    if (!completelyVisible) {
        [self.categoriesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        [self changeToSelectedIndexPath:indexPath ofCategoryType:self.selectedCategoryType withAnimation:YES andLogicBlockWhenFinish:^{
            [self.delegate categorySelectorViewController:self didSelectCategory:[self findCategoryOfCellAtIndexPath:indexPath]];
        }];
    }
}

- (BOOL)isCompletelyVisibleCellIndexPath:(NSIndexPath *)indexPath
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView cellForRowAtIndexPath:indexPath];
    CGRect normalizedFrame = [self.categoriesTableView convertRect:cell.frame toView:self.categoriesTableView.superview];
    const BOOL isCompletelyVisible = (CGRectContainsRect(self.categoriesTableView.frame, normalizedFrame));
    
    return isCompletelyVisible;
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
    [self configureCategoryLabelOfTableViewCell:cell atIndexPath:indexPath withCategory:category];
    [self configureNumberOfConceptsLabelOfTableViewCell:cell atIndexPath:indexPath withCategory:category];
    [self configureOpenDecoratorViewOfTableViewCell:cell atIndexPath:indexPath withCategory:category];
}

- (void)configureCategoryLabelOfTableViewCell:(IAECategoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withCategory:(IAECategory *)category
{
    const BOOL isGeneralCategory = [[IAECategoryStore sharedCategoryStore] isGeneralCategory:category];
    NSDictionary *attributes = isGeneralCategory ? self.labelAttributesForGeneralCategory : self.labelAttributesForUserCategory;
    cell.categoryLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag]
                                                                        attributes:attributes];
}

- (void)configureNumberOfConceptsLabelOfTableViewCell:(IAECategoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withCategory:(IAECategory *)category
{
    if (self.showNumberOfConcepts) {
        NSUInteger numberOfConceptsOfCategory = [[IAEBook sharedBook] findInOpenYearsAllConceptsWithCategory:category].count;
        cell.numberOfConceptsLabel.text = [IAELocalizerPhraseComposer stringPhraseWithNumberOfConcepts:numberOfConceptsOfCategory];
    }
}

- (void)configureOpenDecoratorViewOfTableViewCell:(IAECategoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withCategory:(IAECategory *)category
{
    const BOOL checkForDecoratorView = ![self isCategorySelectionWithoutDecoratorFlagEnabled] && self.selectedCategoryIndexPath;
    BOOL selectCategory = checkForDecoratorView;
    if (checkForDecoratorView) {
        selectCategory = [self.selectedCategoryIndexPath compare:indexPath] == NSOrderedSame && category.categoryType == self.selectedCategoryType;
    }
    cell.openDecoratorView.hidden = !selectCategory;
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
    BOOL categoryOfCellSelectedHaveConcepts = [[IAEBook sharedBook] findInOpenYearsAllConceptsWithCategory:self.categoryOfCellSelectedToRemove].count > 0;
    if (categoryOfCellSelectedHaveConcepts) {
        [self launchAlertViewBeforeDeleteCategory];
    } else {
        [self sendRemoveCategoryOfCellSelectedActionExecuted];
    }
}

- (void)launchAlertViewBeforeDeleteCategory
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_TITLE", @"")
                                message:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_MESSAGE", @"")
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_CANCELOPTION", @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                       [self exitOfStrokeStateInCellOfSelectedCategory];
                                   }];

    UIAlertAction* removeButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_REMOVECATEGORY_REMOVEOPTION", @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                       [self sendRemoveCategoryOfCellSelectedActionExecuted];
                                   }];

    [alert addAction:cancelButton];
    [alert addAction:removeButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendRemoveCategoryOfCellSelectedActionExecuted
{
    NSAssert(self.categoryOfCellSelectedToRemove, @"");
    [self.delegate categorySelectorViewController:self didSelectRemoveCategory:self.categoryOfCellSelectedToRemove];
    self.categoryOfCellSelectedToRemove = nil;
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
