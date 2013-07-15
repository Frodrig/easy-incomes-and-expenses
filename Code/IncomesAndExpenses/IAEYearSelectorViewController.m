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
@end

@implementation IAEYearSelectorViewController

static NSString * const titleTagActualYear = @"TAG_YEARSELECTOR_ACTUALYEAR";
static NSString * const titleTagWithConceptsYears = @"TAG_YEARSELECTOR_WITHCONCEPTYEARS";
static NSString * const titleTagAllYears = @"TAG_YEARSELECTOR_ALLYEARS";
static NSString * const titleTagYearOpen = @"TAG_YEARSELECTOR_ACTUALOPENYEAR";

static NSString * const nibNameForCollectionViewCell = @"IAEYearSelectorCollectionViewCell";
static NSString * const collectionViewCellReuseIdentifier = @"YearSelectorCollectionViewCell";

static NSString * const fontFamilyForActualYearOpenLabel = @"HelveticaNeue";

static NSUInteger fontFamilySizeForActualYearOpenLabel = 17;

static NSUInteger yearsSegmentedControlActualYearIndex = 0;
static NSUInteger yearsSegmentedControlYearsWithConceptsIndex = 1;
static NSUInteger yearsSegmentedControlAllYearsIndex = 2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureYearsCollectionView];
    [self configureYearBookAndSaveYearLoadedBeforeStart];
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

- (void)configureYearsCollectionView
{
    [self.yearsCollectionView registerNib:[UINib nibWithNibName:nibNameForCollectionViewCell bundle:[NSBundle mainBundle]]
               forCellWithReuseIdentifier:collectionViewCellReuseIdentifier];
    self.yearsCollectionView.dataSource = self;
    self.yearsCollectionView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self vinculeYearsSegmentedControlLabels];
    [self vinculeActualYearOpenLabel];
}

- (void)vinculeYearsSegmentedControlLabels
{
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagActualYear, @"")
                       forSegmentAtIndex:yearsSegmentedControlActualYearIndex];
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagWithConceptsYears, @"")
                       forSegmentAtIndex:yearsSegmentedControlYearsWithConceptsIndex];
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagAllYears, @"")
                       forSegmentAtIndex:yearsSegmentedControlAllYearsIndex];
}

- (void)vinculeActualYearOpenLabel
{
    NSString *textLabel = [NSString stringWithFormat:NSLocalizedString(titleTagYearOpen, @""), self.yearLoadedBeforeStart];
    self.actualYearOpenLabel.attributedText = [[NSAttributedString alloc] initWithString:textLabel
                                                                              attributes:[self createAttributeDictionaryForActualYearOpenLabel]];
}

- (NSDictionary *)createAttributeDictionaryForActualYearOpenLabel
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:fontFamilyForActualYearOpenLabel size:fontFamilySizeForActualYearOpenLabel],
                                  NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

#pragma mark - Button Events

- (IBAction)closeButtonPressed:(id)sender
{
    if (self.yearLoadedBeforeStart != 0) {
        [[IAEBook sharedBook] loadYear:self.yearLoadedBeforeStart];
    }
    
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
    IAEYearSelectorCollectionViewCell *cell = (IAEYearSelectorCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellReuseIdentifier
                                                                                                                             forIndexPath:indexPath];
    [self configureCell:cell WithIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(IAEYearSelectorCollectionViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = [self yearBasedInSegmentedControlStateUsingIndexPath:indexPath];
    BOOL isAValidYearAndHaveConcepts = year && [year findNumberOfConcepts] > 0;
    
    if (isAValidYearAndHaveConcepts) {
        [cell configureWithYearDate:year.yearDate andBalance:[year balance]];
    } else {
        [cell configureWithYearDate:[self yearDateFromIndexPath:indexPath]];
    }
}

- (IAEYear *)yearBasedInSegmentedControlStateUsingIndexPath:(NSIndexPath *)indexPath
{
    IAEYear *year = nil;
    if ([self isSegmentedControlInPresentYearState]) {
        year = [self findYearUsingIndexAccessOfIndexPath:indexPath];
    } else if ([self isSegmentedControlInWithConceptsYearsState]) {
        year = [self findYearUsingIndexAccessOfIndexPath:indexPath];
    } else if ([self isSegmentedCOntrolInAllYearsState]) {
        year = [self findYearUsingYearDateOfIndexPath:indexPath];
    }
    
    return year;
}

- (BOOL)isSegmentedControlInPresentYearState
{
    return self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlActualYearIndex;
}

- (BOOL)isSegmentedControlInWithConceptsYearsState
{
    return self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlYearsWithConceptsIndex;
}

- (BOOL)isSegmentedCOntrolInAllYearsState
{
    return self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlAllYearsIndex;
}

- (IAEYear *)findYearUsingIndexAccessOfIndexPath:(NSIndexPath *)indexPath
{
    NSArray *years = [[IAEBook sharedBook] findAllYearWithConcepts];
    IAEYear *year = years.count > indexPath.row ? [years objectAtIndex:indexPath.row] : nil;
    
    return year;
}

- (IAEYear *)findYearUsingYearDateOfIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDate = [self yearDateFromIndexPath:indexPath];
    IAEYear *year = [[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:yearDate]];
    
    return year;
}

- (NSUInteger)yearDateFromIndexPath:(NSIndexPath *)indexPath
{
    return [IAEDateHelper findActualYear] - indexPath.row;
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
    if ([self isSegmentedControlInPresentYearState]) {
        numberOfItems = [IAEBook sharedBook].years.count > 0 ? 1 : 0;
    } else if ([self isSegmentedControlInWithConceptsYearsState]) {
        numberOfItems = [[IAEBook sharedBook] findAllYearWithConcepts].count;
    } else if ([self isSegmentedCOntrolInAllYearsState]) {
        numberOfItems = [IAEDateHelper findActualYear];
    }
    
    return numberOfItems;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yearDateSelected = [self yearDateBasedInSegmentedControlStateFromIndexPath:indexPath];
    [self chooseActionAfterSelectCellWithYearDate:yearDateSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseActionAfterSelectCellWithYearDate:(NSUInteger)yearDateSelected
{
    if (yearDateSelected == self.yearLoadedBeforeStart) {
        [self actionSelectedActualYear];
    } else if ([[IAEBook sharedBook] findYearWithDate:[NSNumber numberWithUnsignedInteger:yearDateSelected]]) {
        [self actionSelectedYearWithConceptsWithDate:yearDateSelected];
    } else {
        [self actionSelectedYearWithoutConceptsWithDate:yearDateSelected];
    }
}

- (void)actionSelectedActualYear
{
    [[IAEBook sharedBook] loadYear:self.yearLoadedBeforeStart];
    [self.delegate actualYearSelectedWasSelectedInYearSelectorViewController:self];
}

- (void)actionSelectedYearWithConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] loadYear:yearDate];
    [self.delegate yearSelectorViewController:self didLoadSelectedYearDate:yearDate];
}

- (void)actionSelectedYearWithoutConceptsWithDate:(NSUInteger)yearDate
{
    [[IAEBook sharedBook] createYear:[NSNumber numberWithUnsignedInteger:yearDate]];
    [[IAEBook sharedBook] saveAll];
    [[IAEBook sharedBook] loadYear:yearDate];
    
    [self.delegate yearSelectorViewController:self didCreateAndLoadSelectedYearDate:yearDate];
}

@end
