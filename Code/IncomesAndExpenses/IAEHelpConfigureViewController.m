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
#import "IAEHelpIndexViewControllerDelegate.h"

@interface IAEHelpConfigureViewController ()

@end

@implementation IAEHelpConfigureViewController

#pragma mark - Constantes

static NSString * const kCollectionViewConceptsWithDaysCellNibName = @"IAEHelpConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewConceptsWithDaysCellIdentifier = @"IAEConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewStartMonthCellNibName = @"IAEHelpConfigureStartMonthCell";
static NSString * const kCollectionViewStartMonthCellIdentifier = @"IAEConfigureStartMonthCell";

static NSUInteger kNumberOfSections = 2;
static NSUInteger kNumberOfItemsInSection = 1;
static NSUInteger kSectionOfConfigureConceptsWithDaysCell = 0;
static NSUInteger kSectionOfConfigureStartMonthCell = 1;

#pragma mark - Init

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
    
    [self configureNavigationController];
    [self configureCollectionView];
}

- (void)configureCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewConceptsWithDaysCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewConceptsWithDaysCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewStartMonthCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionViewStartMonthCellIdentifier];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_1", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
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
    }
    
    return size;
}

- (NSUInteger)findNumberOfItemsBasedInSegmentedControl
{
    NSUInteger numberOfItems = 1;
    
    return numberOfItems;
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
