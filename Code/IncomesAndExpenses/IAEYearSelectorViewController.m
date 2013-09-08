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
#import "IAEStrokeAnimatableLineView.h"

@interface IAEYearSelectorViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearsSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *yearsCollectionView;
@property (nonatomic) NSUInteger yearLoadedBeforeStart;
@property (weak, nonatomic) IBOutlet UILabel *actualYearOpenLabel;
@property (nonatomic, weak) IAEYearSelectorCollectionViewCell *selectedCellToClean;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
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

static const CGFloat kDurationStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimation = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimation = 1.0;
static const NSUInteger kTypeStrokeAnimation = STROKEANIMATABLE_TYPE_THIN;

static NSString * const kLTextAlertViewConfirmCleanTitle = @"LTEXT_CONFIRM_CLEANYEARCONCEPTS_TITLE";
static NSString * const kLTextAlertViewConfirmCleanMessage = @"LTEXT_CONFIRM_CLEANYEARCONCEPTS_TEXT";
static NSString * const kLTextAlertViewConfirmCancelOption = @"LTEXT_ALERTVIEW_CANCEL";
static NSString * const kLTextAlertViewConfirmCleanOption = @"LTEXT_ALERTVIEW_CLEAN";

static const CGFloat kDurationChangeModeFadeIn = 0.5;
static const CGFloat kDurationChangeModeFadeOut = 0.35;

#pragma mark - Properties

- (IAEStrokeAnimatableLineView *)strokeAnimatableLineView
{
    if (!_strokeAnimatableLineView) {
        _strokeAnimatableLineView = [[IAEStrokeAnimatableLineView alloc] init];
        _strokeAnimatableLineView.durationOfStrokeAnimation = kDurationStrokeAnimation;
        _strokeAnimatableLineView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimation
                                                                  alpha:kColorWhiteAlphaComponentForStrokeAnimation];
        _strokeAnimatableLineView.strokeType = kTypeStrokeAnimation;
        _strokeAnimatableLineView.delegate = self;
    }
    
    return _strokeAnimatableLineView;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self.yearsCollectionView removeGestureRecognizer:self.swipeGestureRecognizer];
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initSwipeGestureRecognizer];
    }
    return self;
}

- (void)initSwipeGestureRecognizer
{
    _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerAction:)];
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
    [self.yearsCollectionView addGestureRecognizer:self.swipeGestureRecognizer];
    
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
    const NSUInteger numberOfConceptsofOpenYear = [year findNumberOfConcepts];
    self.yearsSegmentedControl.selectedSegmentIndex = numberOfConceptsofOpenYear > 0 ? kYearsSegmentedControlYearsWithConceptsIndex : kYearsSegmentedControlAllYearsIndex;
    if (self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlAllYearsIndex) {
        const NSUInteger numberOfYearsWithConcepts = [[IAEBook sharedBook] findAllYearWithConcepts].count;
        if (numberOfYearsWithConcepts == 0) {
            [self.yearsSegmentedControl setEnabled:NO forSegmentAtIndex:kYearsSegmentedControlYearsWithConceptsIndex];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self goToOpenYearScrollPosition];
}

- (void)goToOpenYearScrollPosition
{
    if ([self canGoToOpenYearScrollPosition]) {
        NSIndexPath *indexPath = [self findIndexPathBasedInSegmentedControlIndexUsingYearDate:self.yearLoadedBeforeStart];
        [self.yearsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
}

- (BOOL)canGoToOpenYearScrollPosition
{
    BOOL can = [self isSegmentedControlInAllYearsState];
    if (!can) {
        IAEYear *year = [[IAEBook sharedBook] findYearWithDate:@(self.yearLoadedBeforeStart)];
        can = [self isSegmentedControlInWithConceptsYearsState] && [year findNumberOfConcepts] > 0;
    }
    
    return can;
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
    if ([self canChangeTheSelectedSegmentIndex]) {
        [self changeToSelectedSegmentIndex];
    }
}

- (BOOL)canChangeTheSelectedSegmentIndex
{
    return ![self inCleanYearStateAfterSwipeGesture];
}

- (BOOL)inCleanYearStateAfterSwipeGesture
{
    return self.selectedCellToClean != nil;
}

- (void)changeToSelectedSegmentIndex
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationChangeModeFadeIn animations:^{
        self.yearsCollectionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.yearsCollectionView reloadData];
        [self goToOpenYearScrollPosition];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:kDurationChangeModeFadeOut animations:^{
            self.yearsCollectionView.alpha = 1.0;
        }];
    }];
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
    const NSUInteger numItems = [self findNumberOfItemsBasedInYearSegmentedControlValue];
    
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    IAEYearSelectorCollectionViewCell *yearCell = (IAEYearSelectorCollectionViewCell *)cell;
    [yearCell exitFromStrokeModeWithAnimation:NO];
    [self.strokeAnimatableLineView resetStroke];
}

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

- (void)swipeGestureRecognizerAction:(UIGestureRecognizer *)gestureRecognizer
{
    NSIndexPath *locationIndexPath = [self findIndexPathOfCellUnderGestureRecognizer:gestureRecognizer];
    if ([self canCleanYearAtIndexPath:locationIndexPath]) {
        self.selectedCellToClean = (IAEYearSelectorCollectionViewCell *)[self.yearsCollectionView cellForItemAtIndexPath:locationIndexPath];
        [self.strokeAnimatableLineView doStrokeOverTheView:self.selectedCellToClean.containerForStrokeView];
        [self.selectedCellToClean goToStrokeModeWithAnimation:YES];
    }
}

- (NSIndexPath *)findIndexPathOfCellUnderGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.yearsCollectionView];
    NSIndexPath *locationIndexPath = [self.yearsCollectionView indexPathForItemAtPoint:location];

    return locationIndexPath;
}

- (BOOL)canCleanYearAtIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    
    return [year findNumberOfConcepts] > 0;
}

- (void)launchCleanConfirmationAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(kLTextAlertViewConfirmCleanTitle, @"")
                                message:NSLocalizedString(kLTextAlertViewConfirmCleanMessage, @"")
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(kLTextAlertViewConfirmCancelOption, @"")
                                otherButtonTitles:NSLocalizedString(kLTextAlertViewConfirmCleanOption, @""), nil];
        
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kAlertViewCleanButtonIndex) {
        [self cleanYearSelectedAndUpdateControl];
    } else {
        [self.selectedCellToClean exitFromStrokeModeWithAnimation:YES];
        [self.strokeAnimatableLineView resetStroke];
    }
}

- (void)cleanYearSelectedAndUpdateControl
{
    NSIndexPath *indexPathOfSelectedCellToClean = [self.yearsCollectionView indexPathForCell:self.selectedCellToClean];
    NSUInteger yearDateSelectedForClean = [self yearDateBasedInSegmentedControlStateFromCell:self.selectedCellToClean];
    IAEYear *yearSelectedForClean = [self yearBasedInSegmentedControlStateUsingCell:self.selectedCellToClean];
    [[IAEBook sharedBook] deleteAllConceptsOfYear:yearSelectedForClean];
    [[IAEBook sharedBook] saveAll];
    
    if (yearDateSelectedForClean == self.yearLoadedBeforeStart) {
        [self.delegate yearSelectorViewController:self didCleanOpenYearDate:yearDateSelectedForClean];
    }

    if ([self isSegmentedControlInWithConceptsYearsState]) {
        [self checkAndDisableYearSegmentedControlForYearsWithoutConceptsIfAppropiate];
        if (self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlYearsWithConceptsIndex) {
            [self.yearsCollectionView deleteItemsAtIndexPaths:@[indexPathOfSelectedCellToClean]];
        }
    } else {
        [self checkAndDisableYearSegmentedControlForYearsWithoutConceptsIfAppropiate];
        [self.selectedCellToClean exitFromStrokeModeWithAnimation:NO];
        [self.strokeAnimatableLineView resetStroke];
        [self.yearsCollectionView reloadItemsAtIndexPaths:@[indexPathOfSelectedCellToClean]];
    }
    
    self.selectedCellToClean = nil;
}

- (void)checkAndDisableYearSegmentedControlForYearsWithoutConceptsIfAppropiate
{
    const NSUInteger numberOfYearsWithConcepts = [[IAEBook sharedBook] findAllYearWithConcepts].count;
    if (numberOfYearsWithConcepts == 0) {
        // Nota: Al deshabilitar la seccion se resta uno al indice y pasaria a ser menos uno. Guardamos la informacion antes.
        NSLog(@"%d", self.yearsSegmentedControl.selectedSegmentIndex);
        const BOOL wasInYearWithConceptsSection = self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlYearsWithConceptsIndex;
        [self.yearsSegmentedControl setEnabled:NO forSegmentAtIndex:kYearsSegmentedControlYearsWithConceptsIndex];
        NSLog(@"%d", self.yearsSegmentedControl.selectedSegmentIndex);
        if (wasInYearWithConceptsSection) {
            self.yearsSegmentedControl.selectedSegmentIndex = kYearsSegmentedControlAllYearsIndex;
            [self changeToSelectedSegmentIndex];
        }
    }
}

#pragma mark - IAEStrokeAnimatableViewDelegate

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view
{
    [self launchCleanConfirmationAlertView];
}

@end
