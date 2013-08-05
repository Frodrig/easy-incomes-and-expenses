//
//  IAEHelperContextTextRawMenuDataSource.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelperContextTextRawMenuDataSource.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEDateHelper.h"
#import "IAEYear.h"

@interface IAEHelperContextTextRawMenuDataSource()

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> iaeViewControllerQuery;

@end

@implementation IAEHelperContextTextRawMenuDataSource

#pragma mark - Constants

static const NSUInteger kContentScrollViewNumberOfItems = 13;
static const NSUInteger kGlobalIndexForYearInContextScrollView = 0;
static const NSUInteger kContextMenuIndexOfYearOption = 0;
static NSString * const kContextMenuFontFamilyName = @"HelveticaNeue-Ultralight";
static const CGFloat kContextMenuFontSizeOfOptions = 24;
static const CGFloat kContextMenuDefaultKernOfOptions = 1;
static const CGFloat kContextMenuYearKernOfOptions = 0;
static const NSUInteger kBorderMaskForOptions = UIRectCornerBottomLeft | UIRectCornerBottomRight;
static const CGFloat kRadiusOfBorderForOptions = 15;

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

#pragma mark - IAETextRawSelectorMenuViewDataSource

- (NSUInteger)numberOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSUInteger numberOfOptions = kContentScrollViewNumberOfItems;
    
    return numberOfOptions;
}

- (NSString *)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu optionStringNameAtIndex:(NSUInteger)optionIndex
{
    NSString *optionStringName = nil;
    
    if (optionIndex == kContextMenuIndexOfYearOption) {
        optionStringName = [NSString stringWithFormat:@"%d", [self.iaeViewControllerQuery findOpenYear].yearDate];
    } else {
        optionStringName = [IAEDateHelper findMonthNameStringWithMonthIndex:optionIndex inShortForm:YES];
    }

    return optionStringName;
}

- (UIColor *)colorForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    return [UIColor blackColor];
}

- (CGSize)sizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGFloat width = [self.iaeViewControllerQuery findMainViewSize].width / kContentScrollViewNumberOfItems;
    CGSize size = CGSizeMake(width, 44);
    
    return size;
}

- (NSString *)fontFamilyNameOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    NSString *fontFamily = kContextMenuFontFamilyName;
    
    return fontFamily;
}

- (CGFloat)fontSizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    CGFloat fontSize = kContextMenuFontSizeOfOptions;
    
    return fontSize;
}

- (CGFloat)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu kernOfOptionsAtIndex:(NSUInteger)optionIndex
{
    CGFloat kern = kContextMenuDefaultKernOfOptions;
    if (optionIndex == kContextMenuIndexOfYearOption) {
        kern = kContextMenuYearKernOfOptions;
    }
    
    return kern;
}

- (IAETextRawSelectorMenuViewSelectorType)selectorTypeInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    IAETextRawSelectorMenuViewSelectorType selectorType = TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR;
    
    return selectorType;
}

- (UIColor *)colorForSelectorIndicatorInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu
{
    UIColor *color = [UIColor colorWithWhite:0.9 alpha:0.3];
    
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
