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
#import "IAECurrencyManager.h"
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
static NSString * const kLtextBaseTextForHeaderInfo = @"LTEXT_EDITMODECONCEPTHEADER_BASEINFO";

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
    NSUInteger numberOfItems = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContext:section];
    
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
    NSString *monthBalance = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[month balance]];
    NSString *info = [NSString stringWithFormat:NSLocalizedString(kLtextBaseTextForHeaderInfo, @""), monthBalance, month.concepts.count];
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
    NSString *amountWithSignString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:amountWithSign];
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    UIColor *colorForEconomicValueType = [IAEColorHelper colorForEconomicValueType:economicValueType];
    NSUInteger instantEntryIndex = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContext:indexPath.section] - indexPath.row;
    
    cell.valueDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:amountWithSign];
    [self configureCategoryLabelsOfConceptCell:cell withCategory:category];
    [self configureAmountLabelOfConceptCell:cell withAmountWithSignString:amountWithSignString andColor:colorForEconomicValueType];
    [self configureIdentifierOfConceptCell:cell atIndexPath:indexPath withIndex:instantEntryIndex];
}

- (void)configureCategoryLabelsOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                                withCategory:(IAECategory *)category
{
    NSDictionary *categoryNameLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptNameLabelInConceptCell]
                                                                                             andColor:[UIColor blackColor]];
    cell.categoryNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedTag]
                                                                            attributes:categoryNameLabelAttributes];
    
    NSDictionary *categoryTypeLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForCategoryConceptTypeLabelInConceptCell] andColor:[UIColor blackColor]];
    cell.categoryTypeLabel.attributedText = [[NSAttributedString alloc] initWithString:[category localizedCategoryTypeString] attributes:categoryTypeLabelAttributes];
    
}

- (void)configureAmountLabelOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                 withAmountWithSignString:(NSString *)amountSignedString
                                 andColor:(UIColor *)color
{
    NSDictionary *amountLabelAttributes = [self createAttributeDictionaryForConceptCellWithFont:[self createFontForAmountLabelInConceptCell]
                                                                                       andColor:color];
    cell.amountLabel.attributedText = [[NSAttributedString alloc] initWithString:amountSignedString attributes:amountLabelAttributes];
}

- (NSDictionary *)createAttributeDictionaryForConceptCellWithFont:(UIFont *)font andColor:(UIColor *)color
{
    NSDictionary *attributes =  @{NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForAmountLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:52];
    return font;
}

- (UIFont *)createFontForCategoryConceptNameLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
    return font;
}

- (UIFont *)createFontForCategoryConceptTypeLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17];
    return font;
}

- (void)configureIdentifierOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath
                               withIndex:(NSUInteger)index
{
    NSLog(@"configure with index %d", index);

    if (![self.iaeViewControllerQuery isDayModeActiveForConcepts]) {
        [cell setIdentifierWithEntryInstantIndex:index];
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
