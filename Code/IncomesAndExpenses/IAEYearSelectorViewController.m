//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearSelectorViewController.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEYearSelectorCollectionViewCell.h"
#import "IAEDateHelper.h"
#import "IAEBook.h"
#import "IAEYear.h"

@interface IAEYearSelectorViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearsSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *yearsCollectionView;
@property (nonatomic) NSUInteger yearLoadedBeforeStart;
@property (weak, nonatomic) IBOutlet UILabel *actualYearOpenLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) IAEYearSelectorCollectionViewCell *selectedCellWithActionMenu;
@end

@implementation IAEYearSelectorViewController

static NSString * const kTitleTagWithConceptsYears = @"LTEXT_YEARSELECTOR_WITHCONCEPTYEARS";
static NSString * const kTitleTagAllYears = @"LTEXT_YEARSELECTOR_ALLYEARS";
static NSString * const kTitleTagYearOpen = @"LTEXT_YEARSELECTOR_ACTUALOPENYEAR";

static NSString * const kNibNameForCollectionViewCell = @"IAEYearSelectorCollectionViewCell";
static NSString * const kCollectionViewCellReuseIdentifier = @"YearSelectorCollectionViewCell";

static NSString * const kFontFamilyForActualYearOpenLabel = @"HelveticaNeue";

static const NSUInteger kFontFamilySizeForActualYearOpenLabel = 17;

static const NSUInteger kYearsSegmentedControlYearsWithConceptsIndex = 0;
static const NSUInteger kYearsSegmentedControlAllYearsIndex = 1;

static const NSUInteger kAlertViewCleanButtonIndex = 1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initLongPressGestureRecognizer];
    }
    return self;
}

- (void)initLongPressGestureRecognizer
{
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureYearsCollectionView];
    [self configureYearBookAndSaveYearLoadedBeforeStart];
    [self configureActualYearOpenLabel];
    [self configureYearsSegmentedControlLabels];
    [self configureYearsSegmentedControlInitialState];
}

- (void)configureYearsCollectionView
{
    [self.yearsCollectionView registerNib:[UINib nibWithNibName:kNibNameForCollectionViewCell bundle:[NSBundle mainBundle]]
               forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    self.yearsCollectionView.allowsSelection = YES;
    [self.yearsCollectionView addGestureRecognizer:self.longPressGestureRecognizer];
    
    self.yearsCollectionView.dataSource = self;
    self.yearsCollectionView.delegate = self;
}

- (void)configureYearBookAndSaveYearLoadedBeforeStart
{
    if ([IAEBook sharedBook].years.count > 0) {
        IAEYear *yearLoadedBeforeStart = [[IAEBook sharedBook] findActualYear];
        self.yearLoadedBeforeStart = yearLoadedBeforeStart.yearDate;
    }
    
    [[IAEBook sharedBook] deleteYearsWithZeroConceptsPreservingActualYear];
    [[IAEBook sharedBook] loadAll];
}

- (void)configureActualYearOpenLabel
{
    NSString *textLabel = [NSString stringWithFormat:NSLocalizedString(kTitleTagYearOpen, @""), self.yearLoadedBeforeStart];
    self.actualYearOpenLabel.attributedText = [[NSAttributedString alloc] initWithString:textLabel
                                                                              attributes:[self createAttributeDictionaryForActualYearOpenLabel]];
}

- (void)configureYearsSegmentedControlLabels
{
    [self.yearsSegmentedControl setTitle:NSLocalizedString(kTitleTagWithConceptsYears, @"")
                       forSegmentAtIndex:kYearsSegmentedControlYearsWithConceptsIndex];
    [self.yearsSegmentedControl setTitle:NSLocalizedString(kTitleTagAllYears, @"")
                       forSegmentAtIndex:kYearsSegmentedControlAllYearsIndex];
}

- (void)configureYearsSegmentedControlInitialState
{
    IAEYear *year = [[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:self.yearLoadedBeforeStart]];
    self.yearsSegmentedControl.selectedSegmentIndex = [year findNumberOfConcepts] > 0 ? kYearsSegmentedControlYearsWithConceptsIndex : kYearsSegmentedControlAllYearsIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeInitialScrollPositionForYears];
}

- (void)vinculeInitialScrollPositionForYears
{
    NSIndexPath *indexPath = [self findIndexPathBasedInSegmentedControlIndexUsingYearDate:self.yearLoadedBeforeStart];
    [self.yearsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (NSIndexPath *)findIndexPathBasedInSegmentedControlIndexUsingYearDate:(NSUInteger)yearDate
{
    NSIndexPath *indexPath = nil;
    if ([self isSegmentedControlInWithConceptsYearsState]) {
        IAEYear *year = [[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:yearDate]];
        indexPath = [NSIndexPath indexPathForRow:[[[IAEBook sharedBook] findAllYearWithConcepts] indexOfObject:year] inSection:0];
    } else if ([self isSegmentedControlInAllYearsState]) {
        indexPath = [NSIndexPath indexPathForRow:[IAEDateHelper findActualYearDate] - yearDate inSection:0];
    }
    
    return indexPath;
}

- (NSDictionary *)createAttributeDictionaryForActualYearOpenLabel
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyForActualYearOpenLabel size:kFontFamilySizeForActualYearOpenLabel],
                                  NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (void)dealloc
{
    [self.yearsCollectionView removeGestureRecognizer:self.longPressGestureRecognizer];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Button Events

- (IBAction)closeButtonPressed:(id)sender
{
    NSAssert(self.yearLoadedBeforeStart != 0, @"");
    [[IAEBook sharedBook] loadYear:self.yearLoadedBeforeStart];
    [self.delegate closeButtonWasPressedInYearSelectorViewController:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)yearSegmentedControlPressed:(id)sender
{
    [self.yearsCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(collectionView == self.yearsCollectionView, @"");
    IAEYearSelectorCollectionViewCell *cell = (IAEYearSelectorCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier
                                                                                                                             forIndexPath:indexPath];
    [self configureCell:cell WithIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(IAEYearSelectorCollectionViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    BOOL isAValidYearAndHaveConcepts = year && [year findNumberOfConcepts] > 0;
    
    if (isAValidYearAndHaveConcepts) {
        [cell configureWithYearDate:year.yearDate balance:[year balance] andNumberOfConcepts:[year findNumberOfConcepts]];
    } else {
        [cell configureWithYearDate:[self yearDateFromIndexPath:indexPath]];
    }
    
    cell.showOpenYearDecorator = year.yearDate == self.yearLoadedBeforeStart;
}

- (IAEYear *)yearBasedInSegmentedControlStateUsingIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = nil;
    if ([self isSegmentedControlInWithConceptsYearsState]) {
        year = [self findYearUsingIndexAccessOfIndexPath:indexPath];
    } else if ([self isSegmentedControlInAllYearsState]) {
        year = [self findYearUsingYearDateOfIndexPath:indexPath];
    }
    
    return year;
}

- (NSUInteger)yearDateBasedInSegmentedControlStateUsingIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDate = 0;
    if ([self isSegmentedControlInWithConceptsYearsState]) {
        yearDate = [self findDateYearUsingIndexAccessOfIndexPath:indexPath];
    } else if ([self isSegmentedControlInAllYearsState]) {
        yearDate = [self findDateYearUsingYearDateOfIndexPath:indexPath];
    }
    
    return yearDate;
}

- (IAEYear *)yearBasedInSegmentedControlStateUsingCell:(IAEYearSelectorCollectionViewCell *)cell
{
    return [self yearBasedInSegmentedControlStateUsingIndexPath:[self.yearsCollectionView indexPathForCell:cell]];
}

- (NSUInteger)yearDateBasedInSegmentedControlStateUsingCell:(IAEYearSelectorCollectionViewCell *)cell
{
    return [self yearDateBasedInSegmentedControlStateUsingIndexPath:[self.yearsCollectionView indexPathForCell:cell]];
}

- (BOOL)isSegmentedControlInWithConceptsYearsState
{
    return self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlYearsWithConceptsIndex;
}

- (BOOL)isSegmentedControlInAllYearsState
{
    return self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlAllYearsIndex;
}

- (IAEYear *)findYearUsingYearDate:(NSUInteger)yearDate
{
    IAEYear *year = [[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:yearDate]];
    
    return year;
}

- (IAEYear *)findYearUsingIndexAccessOfIndexPath:(NSIndexPath *)indexPath
{
    NSArray *years = [[IAEBook sharedBook] findAllYearWithConcepts];
    IAEYear *year = years.count > indexPath.row ? [years objectAtIndex:indexPath.row] : nil;
    
    return year;
}

- (NSUInteger)findDateYearUsingIndexAccessOfIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = [self findYearUsingIndexAccessOfIndexPath:indexPath];
    return year ? year.yearDate : 0;
}

- (IAEYear *)findYearUsingYearDateOfIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDate = [self yearDateFromIndexPath:indexPath];
    NSNumber *numberWithYearDate = [NSNumber numberWithUnsignedInteger:yearDate];
    IAEYear *year = [[IAEBook sharedBook] findYearWithDate:numberWithYearDate];
    
    return year;
}

- (NSUInteger)findDateYearUsingYearDateOfIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDate = [self yearDateFromIndexPath:indexPath];
    
    return yearDate;
}

- (NSUInteger)yearDateFromIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger actualYearDate = [IAEDateHelper findActualYearDate];
    NSUInteger yearDate = actualYearDate - indexPath.row;

    return yearDate;
}

- (NSUInteger)yearDateBasedInSegmentedControlStateFromCell:(UICollectionViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.yearsCollectionView indexPathForCell:cell];
    return [self yearDateBasedInSegmentedControlStateFromIndexPath:cellIndexPath];
}

- (NSUInteger)yearDateBasedInSegmentedControlStateFromIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    
    return year != nil ? year.yearDate : [self yearDateFromIndexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numItems = [self findNumberOfItemsBasedInYearSegmentedControlValue];
    return numItems;
}

- (NSUInteger)findNumberOfItemsBasedInYearSegmentedControlValue
{
    NSUInteger numberOfItems = 0;
    if ([self isSegmentedControlInWithConceptsYearsState]) {
        numberOfItems = [[IAEBook sharedBook] findAllYearWithConcepts].count;
    } else if ([self isSegmentedControlInAllYearsState]) {
        numberOfItems = [IAEDateHelper findActualYearDate];
    }
    
    return numberOfItems;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendToDelegateTheChosenActionAfterSelectCellWithYearDate:[self yearDateBasedInSegmentedControlStateUsingIndexPath:indexPath]];
    [self dismissViewControllerAnimated:YES completion:nil];

    //[self launchMenuOfOptionsAtYearCellIndexPathIfProceed:indexPath];
}

- (void)sendToDelegateTheChosenActionAfterSelectCellWithYearDate:(NSUInteger)yearDateSelected
{
    if (yearDateSelected == self.yearLoadedBeforeStart) {
        [self sendToDelegateActionChosenSelectedActualYear];
    } else if ([[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:yearDateSelected]]) {
        [self sendToDelegateActionChosenSelectedYearWithConceptsWithDate:yearDateSelected];
    } else {
        [self sendToDelegateActionChosenSelectedYearWithoutConceptsWithDate:yearDateSelected];
    }
}

- (void)sendToDelegateActionChosenSelectedActualYear
{
    [[IAEBook sharedBook] loadYear:self.yearLoadedBeforeStart];
    [self.delegate openYearSelectedWasSelectedInYearSelectorViewController:self];
}

- (void)sendToDelegateActionChosenSelectedYearWithConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] loadYear:yearDate];
    [self.delegate yearSelectorViewController:self didLoadSelectedYearDate:yearDate];
}

- (void)sendToDelegateActionChosenSelectedYearWithoutConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithUnsignedInteger:yearDate]];
    [[IAEBook sharedBook] saveAll];
    [[IAEBook sharedBook] loadYear:yearDate];
    
    [self.delegate yearSelectorViewController:self didCreateAndLoadSelectedYearDate:yearDate];
}

#pragma mark - UIGestureRecognizer

- (void)longPressGestureRecognizerAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [self findCellOfYearAndLaunchMenuOfOptionsUnderLongPressGestureRecognizer:longPressGestureRecognizer];
}

- (void)findCellOfYearAndLaunchMenuOfOptionsUnderLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    NSIndexPath *locationIndexPath = [self findIndexPathOfCellUnderLongPressGestureRecognizer:longPressGestureRecognizer];
    [self launchMenuOfOptionsAtYearCellIndexPathIfProceed:locationIndexPath];
}

- (NSIndexPath *)findIndexPathOfCellUnderLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    CGPoint location = [longPressGestureRecognizer locationInView:self.yearsCollectionView];
    NSIndexPath *locationIndexPath = [self.yearsCollectionView indexPathForItemAtPoint:location];

    return locationIndexPath;
}

- (void)launchMenuOfOptionsAtYearCellIndexPathIfProceed:(NSIndexPath *)cellIndexPath
{
    self.selectedCellWithActionMenu = nil;
    if (cellIndexPath) {
        [self becomeFirstResponder];
            
        self.selectedCellWithActionMenu = (IAEYearSelectorCollectionViewCell *)[self.yearsCollectionView cellForItemAtIndexPath:cellIndexPath];
            
        UIMenuController *menu = [UIMenuController sharedMenuController];
        BOOL menuWithOpenAndCleanActions = [self yearBasedInSegmentedControlStateUsingIndexPath:cellIndexPath] != nil;
        menu.menuItems = menuWithOpenAndCleanActions ? [self createMenuItemsContainerForOpenAndCleanActions] :
                                                       [self createMenuItemContainerForOpenAction];
        [menu setTargetRect:self.selectedCellWithActionMenu.frame inView:self.yearsCollectionView];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)createMenuItemsContainerForOpenAndCleanActions
{
    return [NSArray arrayWithObjects:[self createMenuItemForOpenAction], [self createMenuItemForCleanAction], nil];
}

- (NSArray *)createMenuItemContainerForOpenAction
{
    return [NSArray arrayWithObject:[self createMenuItemForOpenAction]];
}

- (UIMenuItem *)createMenuItemForOpenAction
{
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_YEARSELECTOR_OPENACTION", @"")
                                                      action:@selector(openActionMenuSelected:)];
    
    return menuItem;
}

- (UIMenuItem *)createMenuItemForCleanAction
{
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_YEARSELECTOR_CLEANACTION", @"")
                                                      action:@selector(cleanActionMenuSelected:)];
    
    return menuItem;
}

- (void)openActionMenuSelected:(id)sender
{
    NSUInteger yearDateOfSelectedCellWithActionMenu = [self yearDateBasedInSegmentedControlStateUsingCell:self.selectedCellWithActionMenu];
    [self sendToDelegateTheChosenActionAfterSelectCellWithYearDate:yearDateOfSelectedCellWithActionMenu];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cleanActionMenuSelected:(id)sender
{
    IAEYear *yearOfSelectedCellWithActionMenu = [self yearBasedInSegmentedControlStateUsingCell:self.selectedCellWithActionMenu];
    NSAssert(yearOfSelectedCellWithActionMenu, @"");
    if ([yearOfSelectedCellWithActionMenu findNumberOfConcepts] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"LTEXT_CONFIRM_CLEANYEARCONCEPTS_TITLE", @"")
                                  message:NSLocalizedString(@"LTEXT_CONFIRM_CLEANYEARCONCEPTS_TEXT", @"")
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"LTEXT_ALERTVIEW_CANCEL", @"")
                                  otherButtonTitles:NSLocalizedString(@"LTEXT_ALERTVIEW_CLEAN", @""), nil];
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kAlertViewCleanButtonIndex) {
        [self cleanYearSelectedWithActionMenu];
    }
    
    self.selectedCellWithActionMenu = nil;
}

- (void)cleanYearSelectedWithActionMenu
{
    NSUInteger yearDateSelectedForClean = [self yearDateBasedInSegmentedControlStateFromCell:self.selectedCellWithActionMenu];
    IAEYear *yearSelectedForClean = [self yearBasedInSegmentedControlStateUsingCell:self.selectedCellWithActionMenu];
    [[IAEBook sharedBook] deleteAllConceptsOfYear:yearSelectedForClean];
    [[IAEBook sharedBook] saveAll];
    
    if (yearDateSelectedForClean == self.yearLoadedBeforeStart) {
        [self.delegate yearSelectorViewController:self didCleanOpenYearDate:yearDateSelectedForClean];
    }
    
    [self.yearsCollectionView reloadData];
}

@end
