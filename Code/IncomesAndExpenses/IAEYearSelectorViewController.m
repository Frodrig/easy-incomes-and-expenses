//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearSelectorViewController.h"
#import "Flurry.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEYearSelectorCollectionViewCell.h"
#import "IAEDateHelper.h"
#import "IAEBook.h"
#import "IAEOpenYear.h"
#import "IAEStrokeAnimatableLineView.h"

@interface IAEYearSelectorViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearsSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *yearsCollectionView;
@property (nonatomic) NSUInteger openYearDateBeforeStart;
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
    if ([IAEBook sharedBook].openYears.count > 0) {
        IAEOpenYear *openYearBeforeStart = [[IAEBook sharedBook] findActualOpenYear];
        self.openYearDateBeforeStart = openYearBeforeStart.yearDate;
    }
    
    [[IAEBook sharedBook] openAll];
}

- (void)configureActualYearOpenLabel
{
    NSString *openYearIdentificationTag = [IAEDateHelper createYearIdentificationTagFromYearDate:self.openYearDateBeforeStart];
    NSString *textLabel = [NSString stringWithFormat:NSLocalizedString(kTitleTagYearOpen, @""), openYearIdentificationTag];
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
    IAEOpenYear *year = [[IAEBook sharedBook] findOpenYearWithDate:@(self.openYearDateBeforeStart)];
    const NSUInteger numberOfConceptsofOpenYear = [year findNumberOfConcepts];
    self.yearsSegmentedControl.selectedSegmentIndex = numberOfConceptsofOpenYear > 0 ? kYearsSegmentedControlYearsWithConceptsIndex : kYearsSegmentedControlAllYearsIndex;
    if (self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlAllYearsIndex) {
        const NSUInteger numberOfYearsWithConcepts = [[IAEBook sharedBook] findAllOpenYearsWithConcepts].count;
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
        NSIndexPath *indexPath = [self findIndexPathBasedInSegmentedControlIndexUsingYearDate:self.openYearDateBeforeStart];
        [self.yearsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
}

- (BOOL)canGoToOpenYearScrollPosition
{
    BOOL can = [self isSegmentedControlInAllYearsState];
    if (!can) {
        IAEOpenYear *year = [[IAEBook sharedBook] findOpenYearWithDate:@(self.openYearDateBeforeStart)];
        can = [self isSegmentedControlInWithConceptsYearsState] && [year findNumberOfConcepts] > 0;
    }
    
    return can;
}

- (NSIndexPath *)findIndexPathBasedInSegmentedControlIndexUsingYearDate:(NSUInteger)yearDate
{
    NSIndexPath *indexPath = nil;
    if ([self isSegmentedControlInWithConceptsYearsState]) {
        IAEOpenYear *year = [[IAEBook sharedBook] findOpenYearWithDate:@(yearDate)];
        indexPath = [NSIndexPath indexPathForRow:[[[IAEBook sharedBook] findAllOpenYearsWithConcepts] indexOfObject:year] inSection:0];
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
    NSAssert(self.openYearDateBeforeStart != 0, @"");
    [[IAEBook sharedBook] saveCloseAllAndOpenYearWithDate:@(self.openYearDateBeforeStart)];
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
    IAEOpenYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    BOOL isAValidYearAndHaveConcepts = year && [year findNumberOfConcepts] > 0;
    
    if (isAValidYearAndHaveConcepts) {
        [cell configureWithYearDate:year.yearDate balance:[year balance] andNumberOfConcepts:[year findNumberOfConcepts]];
    } else {
        [cell configureWithYearDate:[self yearDateFromIndexPath:indexPath]];
    }
    
    cell.showOpenYearDecorator = year.yearDate == self.openYearDateBeforeStart;
}

- (IAEOpenYear *)yearBasedInSegmentedControlStateUsingIndexPath:(NSIndexPath *)indexPath
{
    IAEOpenYear *year = nil;
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

- (IAEOpenYear *)yearBasedInSegmentedControlStateUsingCell:(IAEYearSelectorCollectionViewCell *)cell
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

- (IAEOpenYear *)findYearUsingYearDate:(NSUInteger)yearDate
{
    IAEOpenYear *year = [[IAEBook sharedBook] findOpenYearWithDate:@(yearDate)];
    
    return year;
}

- (IAEOpenYear *)findYearUsingIndexAccessOfIndexPath:(NSIndexPath *)indexPath
{
    NSArray *years = [[IAEBook sharedBook] findAllOpenYearsWithConcepts];
    IAEOpenYear *year = years.count > indexPath.row ? [years objectAtIndex:indexPath.row] : nil;
    
    return year;
}

- (NSUInteger)findDateYearUsingIndexAccessOfIndexPath:(NSIndexPath *)indexPath
{
    IAEOpenYear *year = [self findYearUsingIndexAccessOfIndexPath:indexPath];
    return year ? year.yearDate : 0;
}

- (IAEOpenYear *)findYearUsingYearDateOfIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDate = [self yearDateFromIndexPath:indexPath];
    NSNumber *numberWithYearDate = [NSNumber numberWithUnsignedInteger:yearDate];
    IAEOpenYear *year = [[IAEBook sharedBook] findOpenYearWithDate:numberWithYearDate];
    
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
    IAEOpenYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    
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
        numberOfItems = [[IAEBook sharedBook] findAllOpenYearsWithConcepts].count;
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
    NSUInteger yearDate = [self yearDateBasedInSegmentedControlStateUsingIndexPath:indexPath];
    [self sendToDelegateTheChosenActionAfterSelectCellWithYearDate:yearDate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendToDelegateTheChosenActionAfterSelectCellWithYearDate:(NSUInteger)yearDateSelected
{
    [Flurry logEvent:@"year_open" withParameters:@{@"year" :@(yearDateSelected)}];

    if (yearDateSelected == self.openYearDateBeforeStart) {
        [self sendToDelegateActionChosenSelectedActualYear];
    } else if ([[IAEBook sharedBook] findOpenYearWithDate:@(yearDateSelected)]) {
        [self sendToDelegateActionChosenSelectedYearWithConceptsWithDate:yearDateSelected];
    } else {
        [self sendToDelegateActionChosenSelectedYearWithoutConceptsWithDate:yearDateSelected];
    }
}

- (void)sendToDelegateActionChosenSelectedActualYear
{
    [[IAEBook sharedBook] saveCloseAllAndOpenYearWithDate:@(self.openYearDateBeforeStart)];
    [self.delegate openYearSelectedWasSelectedInYearSelectorViewController:self];
}

- (void)sendToDelegateActionChosenSelectedYearWithConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] saveCloseAllAndOpenYearWithDate:@(yearDate)];
    [self.delegate yearSelectorViewController:self didLoadSelectedYearDate:yearDate];
}

- (void)sendToDelegateActionChosenSelectedYearWithoutConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] saveCloseAllAndOpenYearWithDate:@(yearDate)];

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
    IAEOpenYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    
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
    IAEOpenYear *yearSelectedForClean = [self yearBasedInSegmentedControlStateUsingCell:self.selectedCellToClean];
    [Flurry logEvent:@"year_clean" withParameters:@{@"year" :@(yearSelectedForClean.yearDate)}];
    [yearSelectedForClean deleteAllConcepts];
    [[IAEBook sharedBook] saveAll];
    
    if (yearDateSelectedForClean == self.openYearDateBeforeStart) {
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
    const NSUInteger numberOfYearsWithConcepts = [[IAEBook sharedBook] findAllOpenYearsWithConcepts].count;
    if (numberOfYearsWithConcepts == 0) {
        // Nota: Al deshabilitar la seccion se resta uno al indice y pasaria a ser menos uno. Guardamos la informacion antes.
        const BOOL wasInYearWithConceptsSection = self.yearsSegmentedControl.selectedSegmentIndex == kYearsSegmentedControlYearsWithConceptsIndex;
        [self.yearsSegmentedControl setEnabled:NO forSegmentAtIndex:kYearsSegmentedControlYearsWithConceptsIndex];
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
