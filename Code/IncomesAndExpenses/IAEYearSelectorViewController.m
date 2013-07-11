//
//  IAEYearsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearSelectorViewController.h"
#import "IAEYearSelectorCollectionViewCell.h"
#import "IAEDateHelper.h"
#import "IAEBook.h"
#import "IAEYear.h"

@interface IAEYearSelectorViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearsSegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *yearsCollectionView;
@property (nonatomic) NSUInteger yearLoadedBeforeStart;
@end

@implementation IAEYearSelectorViewController

static NSString * const titleTagActualYear = @"TAG_YEARSELECTOR_ACTUALYEAR";
static NSString * const titleTagWithConceptsYears = @"TAG_YEARSELECTOR_WITHCONCEPTYEARS";
static NSString * const titleTagAllYears = @"TAG_YEARSELECTOR_ALLYEARS";

static NSString * const nibNameForCollectionViewCell = @"IAEYearSelectorCollectionViewCell";
static NSString * const collectionViewCellReuseIdentifier = @"YearSelectorCollectionViewCell";

static NSUInteger yearsSegmentedControlActualYearIndex = 0;
static NSUInteger yearsSegmentedControlYearsWithConceptsIndex = 1;
static NSUInteger yearsSegmentedControlAllYearsIndex = 2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self configureYearsSegmentedControl];
    [self configureYearsCollectionView];
    [self configureYearBookAndSaveYearLoadedBeforeStart];
}

- (void)configureYearBookAndSaveYearLoadedBeforeStart
{
    if ([IAEBook sharedBook].years.count > 0) {
        IAEYear *yearLoadedBeforeStart = [[IAEBook sharedBook] findActualYear];
        self.yearLoadedBeforeStart = yearLoadedBeforeStart.yearDate;
    }
    
    [[IAEBook sharedBook] loadAll];
}

- (void)configureYearsSegmentedControl
{
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagActualYear, @"")
                       forSegmentAtIndex:yearsSegmentedControlActualYearIndex];
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagWithConceptsYears, @"")
                       forSegmentAtIndex:yearsSegmentedControlYearsWithConceptsIndex];
    [self.yearsSegmentedControl setTitle:NSLocalizedString(titleTagAllYears, @"")
                       forSegmentAtIndex:yearsSegmentedControlAllYearsIndex];
}

- (void)configureYearsCollectionView
{
    [self.yearsCollectionView registerNib:[UINib nibWithNibName:nibNameForCollectionViewCell bundle:[NSBundle mainBundle]]
               forCellWithReuseIdentifier:collectionViewCellReuseIdentifier];
    self.yearsCollectionView.dataSource = self;
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
    IAEYearSelectorCollectionViewCell *cell = (IAEYearSelectorCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellReuseIdentifier forIndexPath:indexPath];
    [self configureCollectionViewCell:cell associatedToYearDate:indexPath.row];
    
    return cell;
}

- (void)configureCollectionViewCell:(IAEYearSelectorCollectionViewCell *)cell associatedToYearDate:(NSUInteger)yearDate
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numItems = [self findNumberOfItemsBasedInYearSegmentedControlValue];
    return numItems;
}

- (NSUInteger)findNumberOfItemsBasedInYearSegmentedControlValue
{
    NSUInteger numberOfItems = 0;
    if (self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlActualYearIndex) {
        numberOfItems = [[IAEBook sharedBook] findActualYear] != nil ? 1 : 0;
    } else if (self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlYearsWithConceptsIndex) {
        numberOfItems = [[IAEBook sharedBook] findAllYearWithConcepts].count;
    } else if (self.yearsSegmentedControl.selectedSegmentIndex == yearsSegmentedControlAllYearsIndex) {
        numberOfItems = [IAEDateHelper findActualYear];
    }
    
    return numberOfItems;
}

@end
