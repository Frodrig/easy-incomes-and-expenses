//
//  IAEHelpConfigureViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureViewController.h"
#import "IAEHelpConfigureConceptsWithDaysCell.h"
#import "IAEHelpConfigureStartMonthCell.h"
#import "IAEHelpConfigureConfirmRemoveConceptCell.h"
#import "IAEHelpIndexViewControllerDelegate.h"
#import "IAEHelpConfigureStartMonthSelectorTableViewController.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEHelpConfigureViewController ()

@property (nonatomic, strong) NSIndexPath *lastIndexPathHighlighted;

@property (nonatomic) MonthType actualInitialMonth;

@end

@implementation IAEHelpConfigureViewController

#pragma mark - Constantes

static NSString * const kCollectionViewConceptsWithDaysCellNibName = @"IAEHelpConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewConceptsWithDaysCellIdentifier = @"IAEConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewStartMonthCellNibName = @"IAEHelpConfigureStartMonthCell";
static NSString * const kCollectionViewStartMonthCellIdentifier = @"IAEConfigureStartMonthCell";
static NSString * const kCollectionViewRemoveConceptsWithConfirmationCellNibName = @"IAEConfirmRemoveConceptCell";
static NSString * const kCollectionViewRemoveConceptsWithConfirmationCellIdentifier = @"IAEConfigureConfirmRemoveConceptCell";

static NSUInteger kNumberOfSections = 3;
static NSUInteger kNumberOfItemsInSection = 1;
static NSUInteger kSectionOfConfigureConceptsWithDaysCell = 0;
static NSUInteger kSectionOfConfigureStartMonthCell = 1;
static NSUInteger kSectionOfRemoveConceptsWithConfirmationCell = 2;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _actualInitialMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationController];
    [self configureCollectionView];
}

- (void)configureCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewConceptsWithDaysCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewConceptsWithDaysCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewStartMonthCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewStartMonthCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewRemoveConceptsWithConfirmationCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewRemoveConceptsWithConfirmationCellIdentifier];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_1", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self adjustValuesBeforeViewAppear];
}

- (void)adjustValuesBeforeViewAppear
{
    MonthType actualInitialMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
    if (actualInitialMonth != self.actualInitialMonth) {
        self.actualInitialMonth = actualInitialMonth;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kSectionOfConfigureStartMonthCell]];
    }
    
    [self backgroundColorInCellAtIndexPath:self.lastIndexPathHighlighted highlighted:NO];
}

#pragma mark - Navigation Bar

- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.delegate dismissAll];
}

#pragma mark - UICollectionViewFlowDelegate

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(0, 0);
    if (indexPath.section == kSectionOfConfigureConceptsWithDaysCell) {
        size = [IAEHelpConfigureConceptsWithDaysCell sizeOfItem];
    } else if (indexPath.section == kSectionOfConfigureStartMonthCell) {
        size = [IAEHelpConfigureStartMonthCell sizeOfItem];
    } else if (indexPath.section == kSectionOfRemoveConceptsWithConfirmationCell) {
        size = [IAEHelpConfigureConfirmRemoveConceptCell sizeOfItem];
    }
    
    return size;
}

- (NSUInteger)findNumberOfItemsBasedInSegmentedControl
{    
    return 1;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionOfConfigureStartMonthCell) {
        [self backgroundColorInCellAtIndexPath:indexPath highlighted:YES];
        [self launchStartMonthSelector];
    }
}

- (void)backgroundColorInCellAtIndexPath:(NSIndexPath *)indexPath highlighted:(BOOL)highlighted
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.3 animations:^{
        cell.backgroundColor = highlighted ? [UIColor colorWithWhite:0.9 alpha:1.0] : [UIColor clearColor];
    }];
    
    self.lastIndexPathHighlighted = highlighted ? indexPath : nil;
}

- (void)launchStartMonthSelector
{
    IAEHelpConfigureStartMonthSelectorTableViewController *startMonthSelectorViewController = [[IAEHelpConfigureStartMonthSelectorTableViewController alloc] initWithNibName:nil bundle:nil];
    startMonthSelectorViewController.delegate = self.delegate;
    [self.navigationController pushViewController:startMonthSelectorViewController animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (indexPath.section == kSectionOfConfigureConceptsWithDaysCell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewConceptsWithDaysCellIdentifier
                                                         forIndexPath:indexPath];
    } else if (indexPath.section == kSectionOfConfigureStartMonthCell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewStartMonthCellIdentifier
                                                         forIndexPath:indexPath];
    } else if (indexPath.section == kSectionOfRemoveConceptsWithConfirmationCell) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewRemoveConceptsWithConfirmationCellIdentifier
                                                         forIndexPath:indexPath];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kNumberOfItemsInSection;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberOfSections;
}

@end
