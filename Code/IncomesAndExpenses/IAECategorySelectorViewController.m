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

@interface IAECategorySelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, weak) IAECategory *categoryOfCellSelectedToRemove;
@property (nonatomic) NSUInteger actions;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationToolBar;
@property (nonatomic, weak) IAECategory* initialCategory;
@property (nonatomic, strong) NSIndexPath *selectedCategoryIndexPath;

@end

@implementation IAECategorySelectorViewController

static const NSUInteger kIncomeSegmentedIndex = 0;
static const NSUInteger kExpenseSegmentedIndex = 1;

static NSString * const kFontOfGeneralCategoryLabel = @"HelveticaNeue-UltraLightitalic";
static NSString * const kFontOfUserCategoryLabel = @"HelveticaNeue-UltraLight";
static const CGFloat kSizeOfCategoryNameLabel = 28;
static const CGFloat kHeightOfCategoriesCell = 51;

static const CGFloat kDurationOfAnimationOfOpenDecoratorView = 0.1;

static const NSUInteger kButtonIndexOfRemoveConfirmationAlertView = 1;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationItem];
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
        [self changeToSelectedIndexPath:[self findIndexPathOfCategory:self.initialCategory] withAnimation:NO andLogicBlockWhenFinish:nil];
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

- (void)configureCategoriesTableView
{
    [self.categoriesTableView registerNib:[UINib nibWithNibName:@"IAECategoryTableViewCell" bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:@"CategoryTableViewCell"];
    self.categoriesTableView.allowsSelection = [self categorySelectionFlagEnabled];
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    
    if (self.swipeGestureRecognizer) {
        [self.categoriesTableView addGestureRecognizer:self.swipeGestureRecognizer];
    }
}

- (void)reloadData
{
    [self.categoriesTableView reloadData];
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
    [self changeToSelectedIndexPath:indexPathOfCategory withAnimation:animation andLogicBlockWhenFinish:nil];
    [self.categoriesTableView selectRowAtIndexPath:indexPathOfCategory animated:animation scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)changeToSelectedIndexPath:(NSIndexPath *)newSelectedIndexPath
                    withAnimation:(BOOL)animation
          andLogicBlockWhenFinish:(void(^)(void))logicBlock
{
    if ([self isCategorySelectionWithoutDecoratorFlagEnabled]) {
        self.selectedCategoryIndexPath = newSelectedIndexPath;
        if (logicBlock) {
            logicBlock();
        }
    } else {
        void(^animationCoordinationBlock)(void) = ^(void) {
            self.selectedCategoryIndexPath = newSelectedIndexPath;
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
    [self.categoriesTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self changeToSelectedIndexPath:indexPath withAnimation:YES andLogicBlockWhenFinish:^{
        //[self selectAndScrollToCategory:[self findCategoryOfCellAtIndexPath:indexPath] withAnimation:YES];
        [self.delegate categorySelectorViewController:self didSelectCategory:[self findCategoryOfCellAtIndexPath:indexPath]];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightOfCategoriesCell;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell" forIndexPath:indexPath];
    IAECategory *category = [self findCategoryOfCellAtIndexPath:indexPath];
    [self configureTableViewCell:cell withCategory:category];
    
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

- (void)configureTableViewCell:(IAECategoryTableViewCell *)cell withCategory:(IAECategory *)category
{
    NSDictionary *attributes = [self createAttributeDictionaryForCategoryNameAttributeTextWithCategory:category];
    cell.categoryLabel.attributedText = [[NSAttributedString alloc] initWithString:[category description]
                                                                        attributes:attributes];
}

- (NSDictionary *)createAttributeDictionaryForCategoryNameAttributeTextWithCategory:(IAECategory *)category
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForCategoryNameWithCategory:category],
                                  NSForegroundColorAttributeName: [UIColor blackColor],
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
    [self deleteCategoryOfCellUnderLocation:[swipeGestureRecognizer locationInView:self.categoriesTableView]];
}

- (void)deleteCategoryOfCellUnderLocation:(CGPoint)location
{
    self.categoryOfCellSelectedToRemove = [self findCategoryOfCellSelectedUnderLocation:location];
    [self removeCategoryOfCellSelectedIfAppropiateLaunchingConfirmation];
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
        [self removeCategoryOfCellSelected];
    }
}

- (void)launchAlertViewBeforeDeleteCategory
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Confirm remove", @"Advertenciai para confirmar el borrado de una categoria")
                              message:NSLocalizedString(@"There are one or more items with this category. If you remove this category the items will change to the general category associated.", @"Descripcion de lo que ocurrira al borrar una categoria")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Opcion para cancelar el borrado de una categoria")
                              otherButtonTitles:NSLocalizedString(@"Remove", @"Opcion para confirmar el borrado de una categoria"), nil];
    
    [alertView show];
}

- (void)removeCategoryOfCellSelected
{
    NSAssert(self.categoryOfCellSelectedToRemove, @"");
    [self.delegate categorySelectorViewController:self didSelectRemoveCategory:self.categoryOfCellSelectedToRemove];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kButtonIndexOfRemoveConfirmationAlertView) {
        [self removeCategoryOfCellSelected];
    }
}

@end
