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

typedef NS_ENUM(NSUInteger, IAESectionConfigurationOptionType) {
    IAESectionConfigurationOptionConceptsWithDays,
    IAESectionConfigurationOptionRemoveConceptConfirmation,
    IAESectionConfigurationOptionChangeStartMonth,
};

#pragma mark - Constantes

static NSString * const kCollectionViewConceptsWithDaysCellNibName = @"IAEHelpConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewConceptsWithDaysCellIdentifier = @"IAEConfigureConceptsWithDaysCell";
static NSString * const kCollectionViewStartMonthCellNibName = @"IAEHelpConfigureStartMonthCell";
static NSString * const kCollectionViewStartMonthCellIdentifier = @"IAEConfigureStartMonthCell";
static NSString * const kCollectionViewRemoveConceptsWithConfirmationCellNibName = @"IAEConfirmRemoveConceptCell";
static NSString * const kCollectionViewRemoveConceptsWithConfirmationCellIdentifier = @"IAEConfigureConfirmRemoveConceptCell";

#pragma mark - Interface

@interface IAEHelpConfigureViewController ()

@property (nonatomic, strong) NSIndexPath *lastIndexPathHighlighted;
@property (nonatomic) MonthType actualInitialMonth;
@property (nonatomic, strong) NSArray *sectionConfigurationOptionsLiteVersion;
@property (nonatomic, strong) NSArray *sectionConfigurationOptionsProVersion;

@end

#pragma mark - Implementation

@implementation IAEHelpConfigureViewController

#pragma mark - Properties

- (NSArray *)sectionConfigurationOptionsLiteVersion{
    if (!_sectionConfigurationOptionsLiteVersion) {
        _sectionConfigurationOptionsLiteVersion = @[@(IAESectionConfigurationOptionConceptsWithDays)];
    }
    
    return _sectionConfigurationOptionsLiteVersion;
}

- (NSArray *)sectionConfigurationOptionsProVersion
{
    if (!_sectionConfigurationOptionsProVersion) {
        _sectionConfigurationOptionsProVersion = @[@(IAESectionConfigurationOptionConceptsWithDays), @(IAESectionConfigurationOptionRemoveConceptConfirmation), @(IAESectionConfigurationOptionChangeStartMonth)];
    }
    
    return _sectionConfigurationOptionsProVersion;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
     */
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
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[self findSectionIndexForOption:IAESectionConfigurationOptionChangeStartMonth]]];
    }
    
    [self backgroundColorInCellAtIndexPath:self.lastIndexPathHighlighted highlighted:NO];
}

- (NSUInteger)findSectionIndexForOption:(IAESectionConfigurationOptionType)option
{
    NSInteger indexOfOption = [[self findSectionOptionsForActualVersion] indexOfObject:@(option)];
    NSAssert(indexOfOption != NSNotFound, @"");
    return indexOfOption;
}

#pragma mark - Model

- (NSArray *)findSectionOptionsForActualVersion
{
    return [[NSUserDefaults standardUserDefaults] isProVersionEnabled] ? self.sectionConfigurationOptionsProVersion : self.sectionConfigurationOptionsLiteVersion;
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
    if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionConceptsWithDays]) {
        size = [IAEHelpConfigureConceptsWithDaysCell sizeOfItem];
    } else if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionChangeStartMonth]) {
        size = [IAEHelpConfigureStartMonthCell sizeOfItem];
    } else if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionRemoveConceptConfirmation]) {
        size = [IAEHelpConfigureConfirmRemoveConceptCell sizeOfItem];
    }
    
    return size;
}

- (BOOL)isSectionOfIndexPath:(NSIndexPath *)indexPath theOption:(IAESectionConfigurationOptionType)option
{
    IAESectionConfigurationOptionType sectionOptionOfIndexPath = (IAESectionConfigurationOptionType)[[[self findSectionOptionsForActualVersion] objectAtIndex:indexPath.section] unsignedIntegerValue];
    return sectionOptionOfIndexPath == option;
}

- (NSUInteger)findNumberOfItemsBasedInSegmentedControl
{    
    return 1;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionChangeStartMonth]) {
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
    if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionConceptsWithDays]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewConceptsWithDaysCellIdentifier
                                                         forIndexPath:indexPath];
    } else if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionChangeStartMonth]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewStartMonthCellIdentifier
                                                         forIndexPath:indexPath];
    } else if ([self isSectionOfIndexPath:indexPath theOption:IAESectionConfigurationOptionRemoveConceptConfirmation]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewRemoveConceptsWithConfirmationCellIdentifier
                                                         forIndexPath:indexPath];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self findSectionOptionsForActualVersion].count;
}

@end
