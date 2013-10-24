//
//  IAEHelpConfigureViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureViewController.h"
#import "IAEHelpConfigureCollectionViewCell.h"
#import "IAEHelpIndexViewControllerDelegate.h"

@interface IAEHelpConfigureViewController ()

@end

@implementation IAEHelpConfigureViewController

#pragma mark - Constantes

static NSString * const kCollectionViewSettingsCellNibName = @"IAEHelpConfigureCollectionViewCell";
static NSString * const kCollectionviewSettingsCellIdentifier = @"IAEConfigureCell";

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
    [self.collectionView registerNib:[UINib nibWithNibName:kCollectionViewSettingsCellNibName bundle:nil]
          forCellWithReuseIdentifier:kCollectionviewSettingsCellIdentifier];
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
    CGSize size = [IAEHelpConfigureCollectionViewCell sizeOfItem];
    
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionviewSettingsCellIdentifier
                                                                           forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
