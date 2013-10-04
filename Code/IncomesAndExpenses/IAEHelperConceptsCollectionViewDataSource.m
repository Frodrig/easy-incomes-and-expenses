//
//  IAEHelperConceptsCollectionViewDataSource.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelperConceptsCollectionViewDataSource.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEEditModeConceptCollectionViewHeader.h"
#import "IAEValueDecoratorView.h"
#import "IAEMonth.h"
#import "IAEYear.h"
#import "IAEDateHelper.h"
#import "IAEConcept.h"
#import "IAENumberFormatterManager.h"
#import "IAEEconomicValueTypeHelper.h"
#import "IAEColorHelper.h"
#import "IAECategory.h"

@interface IAEHelperConceptsCollectionViewDataSource()

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> iaeViewControllerQuery;

@end

@implementation IAEHelperConceptsCollectionViewDataSource

#pragma mark - Constants

static NSString * const kNibConceptCellName = @"IAEEditModeConceptCollectionViewCell";
static NSString * const kIdConceptCellName = @"EditModeConceptCell";

static NSString * const kCollectionViewHeaderIdentifier = @"EditModeConceptHeader";
static NSString * const kLTextBaseTextForHeaderInfo = @"LTEXT_EDITMODECONCEPTHEADER_BASEINFO";

#pragma mark - Init

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query
{
    self = [super init];
    if (self) {
        _iaeViewControllerQuery = query;
    }
    
    return self;
}

- (id)init
{
    NSAssert(0, @"");
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSUInteger numberOfSections = 1;
    if ([self.iaeViewControllerQuery isActualSelectedContextTheYearOpen]) {
        NSArray *monthWithConcepts = [self.iaeViewControllerQuery findAllOrdererMonthsWithConceptsOfOpenYear];
        numberOfSections = monthWithConcepts.count;
    }
    
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numberOfItems = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:section];
    
    return numberOfItems;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header = nil;
    
    if ([kind compare:UICollectionElementKindSectionHeader] == NSOrderedSame) {
        header = [[self.iaeViewControllerQuery findConceptsCollectionView] dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                 withReuseIdentifier:kCollectionViewHeaderIdentifier
                                                                        forIndexPath:indexPath];
        [self configureEditModeConceptHeader:(IAEEditModeConceptCollectionViewHeader *)header atIndexPath:indexPath];
    }
    
    return header;
}

- (void)configureEditModeConceptHeader:(IAEEditModeConceptCollectionViewHeader *)header atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *months = [self.iaeViewControllerQuery findAllOrdererMonthsWithConceptsOfOpenYear];
    IAEMonth *month = months[indexPath.section];
    NSString *monthName = [IAEDateHelper findMonthNameStringWithMonthIndex:month.month inShortForm:NO];
    NSString *monthBalance = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:[month balance]];
    NSString *info = [NSString stringWithFormat:NSLocalizedString(kLTextBaseTextForHeaderInfo, @""), monthBalance, month.concepts.count];
    header.title = monthName;
    header.info = info;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(collectionView == [self.iaeViewControllerQuery findConceptsCollectionView], @"Se ha recibido una collection view no esperada");
    UICollectionViewCell *cell = [[self.iaeViewControllerQuery findConceptsCollectionView] dequeueReusableCellWithReuseIdentifier:kIdConceptCellName
                                                                                                                     forIndexPath:indexPath];
    
    [self configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:(NSIndexPath *)indexPath
{
    // Nota: Por defecto los conceptos tienen el valor absoluto de la cantidad que almacenan de ahi el pedir la cantidad con signo si procede
    IAEConcept *concept = [self.iaeViewControllerQuery findConceptAtIndexPath:indexPath];
    NSAssert(concept, @"");
    IAECategory *category = concept.category;
    NSAssert(category, @"");
    NSDecimalNumber *amountWithSign = [concept amountWithSign];
    NSString *amountWithSignString = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:amountWithSign];
    const EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    UIColor *colorForEconomicValueType = [IAEColorHelper colorForEconomicValueType:economicValueType];
    const NSUInteger numberOfConcepts = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:indexPath.section];
    NSUInteger instantEntryIndex =  numberOfConcepts - indexPath.row;
    
    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    cell.drawSeparatorLine = indexPath.row != numberOfConcepts - 1;
    [cell setTagWithIndex:index];
    [cell configureCategoryLabelWithName:[category localizedTag]];
    [cell configureAmountLabelWithValue:amountWithSignString andColor:colorForEconomicValueType];
    [self configureIdentifierOfConceptCell:cell atIndexPath:indexPath withIndex:instantEntryIndex];
}

- (void)configureIdentifierOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath
                               withIndex:(NSUInteger)index
{
    if (![self.iaeViewControllerQuery isDayModeActiveForConcepts]) {
        [cell setIdentifierWithEntryInstantIndex:index withAnimationDuration:0];
    } else if ([self isDayOfTheMonthAssociatedWithConceptCell:cell atIndexPath:indexPath]) {
        [self setIdentifierForDayOfTheMonthAndDayOfTheWeekNameForCell:cell atIndexPath:indexPath withIndex:index];
    } else {
        [cell setIdentifierWithoutDay];
    }
}

- (BOOL)isDayOfTheMonthAssociatedWithConceptCell:(IAEEditModeConceptCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    IAEConcept *concept = [self.iaeViewControllerQuery findConceptAtIndexPath:indexPath];
    return concept.dayOfTheMonth != 0;
}

- (void)setIdentifierForDayOfTheMonthAndDayOfTheWeekNameForCell:(IAEEditModeConceptCollectionViewCell *)cell
                                                    atIndexPath:(NSIndexPath *)indexPath
                                                      withIndex:(NSUInteger)index
{
    IAEConcept *concept = [self.iaeViewControllerQuery findConceptAtIndexPath:indexPath];
    NSString *dayOfTheWeekName = [self.iaeViewControllerQuery findDayOfTheWeekNameFromConcept:concept];
    
    [cell setIdentifierWithDayOfTheMonthIndex:concept.dayOfTheMonth andDayOfTheWeekName:dayOfTheWeekName];
}


@end
