//
//  IAEMonthSelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMonthSelectorViewController.h"
#import "IAEMonthSelectorCollectionViewCell.h"
#import "IAEDateHelper.h"

static NSString * const kMonthCellIdentifier = @"MonthCellIdentifier";

@interface IAEMonthSelectorViewController ()<UICollectionViewDataSource,
                                             UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (nonatomic) MonthType actualMonth;
@property (nonatomic, copy) NSSet *invalidInteractionMonths;

@end

@implementation IAEMonthSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"");
    
    return self;
}

- (instancetype)initWithActualMonth:(MonthType)actualMonth andInvalidInteractionMonths:(NSSet *)invalidInteractionMonths
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _actualMonth = actualMonth;
        _invalidInteractionMonths = invalidInteractionMonths;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    [self configureMonthCollectionView];
}

- (void)configureNavigationBar
{
    self.navigationBar.topItem.title = NSLocalizedString(@"LTEXT_MONTHSELECTOR_TITLE", @"");
}

- (void)configureMonthCollectionView
{
    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"IAEMonthSelectorCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kMonthCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IAEMonthSelectorCollectionViewCell *cell = (IAEMonthSelectorCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    return !cell.disabledAspect;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate monthSelectorViewController:self didSelectMonth:[self findMonthTypeForIndexPath:indexPath]];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IAEMonthSelectorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMonthCellIdentifier forIndexPath:indexPath];
    cell.month = [self findMonthTypeForIndexPath:indexPath];
    cell.disabledAspect = ![self canEnableInteractionAtCellAtIndexPath:indexPath];
    
    return cell;
}

- (MonthType)findMonthTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([IAEDateHelper monthTypesArray].count > indexPath.row, @"");
    NSNumber *monthTypeEntry = [IAEDateHelper monthTypesArray][indexPath.row];
    MonthType monthType = (MonthType)monthTypeEntry.integerValue;
    
    return monthType;
}

- (BOOL)canEnableInteractionAtCellAtIndexPath:(NSIndexPath *)indexPath
{
    MonthType monthOfIndexPath = [self findMonthTypeForIndexPath:indexPath];
    BOOL canEnable = monthOfIndexPath != self.actualMonth;
    if (canEnable) {
        canEnable = ![self.invalidInteractionMonths containsObject:@(monthOfIndexPath)];
    }
    
    return canEnable;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [IAEDateHelper monthTypesArray].count;
}

@end
