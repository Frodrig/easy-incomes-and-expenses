//
//  IAEIAEHelperReportTextRawMenuDataSource.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelperReportTextRawMenuDataSource.h"
#import "IAETextRawSelectorMenuViewDataSource.h"
#import "IAEEasyIncomesAndExpensesQuery.h"

@interface IAEHelperReportTextRawMenuDataSource()

@property (nonatomic, weak) IAEEasyIncomesAndExpensesQuery *iaeViewControllerQuery;

@end

@implementation IAEHelperReportTextRawMenuDataSource

#pragma mark - Constants

static NSString * const kLTextReportMenuOptionBalance = @"LTEXT_MENUOPTIONSREPORT_OPTIONBALANCE";
static NSString * const kLTextReportMenuOptionIncomes = @"LTEXT_MENUOPTIONSREPORT_OPTIONINCOMES";
static NSString * const kLTextReportMenuOptionExpenses = @"LTEXT_MENUOPTIONSREPORT_OPTIONEXPENSES";
static const NSUInteger kReportMenuNumberOfItems = 3;
static NSString * const kReportMenuFontFamilyName = @"HelveticaNeue-Ultralight";
static const CGFloat kReportMenuFontSizeOfOptions = 28;
static const CGFloat kReportMenuKernOfOptions = 4;
static const CGFloat kReportMenuItemWidthSize = 200;
static const NSUInteger kBorderMaskForOptions = 0;
static const CGFloat kRadiusOfBorderForOptions = 0;

#pragma mark - Init

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(IAEEasyIncomesAndExpensesQuery *)query
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

#pragma mark - IAETextRawSelectorMenuViewDataSource

- (NSUInteger)numberOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSUInteger numberOfOptions = kReportMenuNumberOfItems;
    
    return numberOfOptions;
}

- (NSString *)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu optionStringNameAtIndex:(NSUInteger)optionIndex
{
    static NSArray *menuOptionsName = nil;
    if (!menuOptionsName) {
        menuOptionsName = @[NSLocalizedString(kLTextReportMenuOptionBalance, @""),
                            NSLocalizedString(kLTextReportMenuOptionIncomes, @""),
                            NSLocalizedString(kLTextReportMenuOptionExpenses, @"")];
    }
    
    NSString *optionStringName = [menuOptionsName objectAtIndex:optionIndex];
    
    return optionStringName;
}

- (UIColor *)colorForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    return [UIColor blackColor];
}

- (CGSize)sizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGSize size = CGSizeMake(kReportMenuItemWidthSize, 44);
    
    return size;
}

- (NSString *)fontFamilyNameOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSString *fontFamily = kReportMenuFontFamilyName;
    
    return fontFamily;
}

- (CGFloat)fontSizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGFloat fontSize = kReportMenuFontSizeOfOptions;
    
    return fontSize;
}

- (CGFloat)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu kernOfOptionsAtIndex:(NSUInteger)optionIndex
{
    CGFloat kern = kReportMenuKernOfOptions;
    
    return kern;
}

- (IAETextRawSelectorMenuViewSelectorType)selectorTypeInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    IAETextRawSelectorMenuViewSelectorType selectorType = TEXTRAWMENUVIEW_SELECTOR_BOTTOMLINE;
    
    return selectorType;
}

- (UIColor *)colorForSelectorIndicatorInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    UIColor *color = [UIColor colorWithWhite:0.9 alpha:1];
    
    return color;
}

- (NSUInteger)borderMaskForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    return kBorderMaskForOptions;
}

- (CGFloat)radiusForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    return kRadiusOfBorderForOptions;
}


@end
