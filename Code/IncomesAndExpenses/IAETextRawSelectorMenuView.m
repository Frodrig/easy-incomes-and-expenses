//
//  IAETextRawSelectorMenuView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAETextRawSelectorMenuView.h"
#import "IAETextRawSelectorMenuViewDataSource.h"
#import "IAETextRawSelectorMenuViewDelegate.h"

@implementation IAETextRawSelectorMenuView

#pragma mark - properties

static NSUInteger tagBaseValue = 100;

- (void)setDataSource:(id<IAETextRawSelectorMenuViewDataSource>)dataSource
{
    if (nil == _dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

- (void)setCurrentOptionIndexSelected:(NSUInteger)optionIndexSelected
{
    // Nota: No generaremos llamada a delegado desde aqui. Solo se generara por evento en controles
    if (optionIndexSelected != _currentOptionIndexSelected && self.dataSource) {
        [self changeIndicatorFromOptionIndex:_currentOptionIndexSelected toNewCurrentOptionIndex:optionIndexSelected];
        _currentOptionIndexSelected = optionIndexSelected;
    }
}

#pragma mark - reloadData

- (void)reloadData
{
    NSAssert(self.dataSource, @"");
    
    [self removeAllMenuOptions];
    [self createAndAddMenuOptions];
    [self adjustFrameUsingMenuOptions];
}

- (void)removeAllMenuOptions
{
    NSMutableSet *menuOptions = [[NSMutableSet alloc] initWithSet:[self findAllMenuOptions]];
    while (menuOptions.count > 0) {
        UIButton *optionToRemove = (UIButton *)[menuOptions anyObject];
        [optionToRemove removeFromSuperview];
        [menuOptions removeObject:optionToRemove];
    }
}

- (NSSet *)findAllMenuOptions
{
    NSMutableSet *menuOptions = [[NSMutableSet alloc] initWithCapacity:self.subviews.count];
    for (UIView *viewIt in self.subviews) {
        if ([viewIt isKindOfClass:[UIButton class]]) {
            [menuOptions addObject:viewIt];
        }
    }
    
    return [NSSet setWithSet:menuOptions];
}

- (void)createAndAddMenuOptions
{
    NSUInteger numberOfOptions = [self.dataSource numberOfOptionsInTextRawSelectorMenu:self];
    for (int optionIt = 0; optionIt < numberOfOptions; optionIt++) {
        UIButton *button = [self createOptionButtonAtIndex:optionIt];
        [self addSubview:button];
    }
}

- (UIButton *)createOptionButtonAtIndex:(NSUInteger)optionIt
{
    UIButton *option = [[UIButton alloc] initWithFrame:[self calculeFrameForOptionButtonAtIndex:optionIt]];
    [option setAttributedTitle:[self createAttributedStringForOptionAtIndex:optionIt] forState:UIControlStateNormal];
    option.backgroundColor = [UIColor clearColor];
    option.tag = [self createTagForButtonAtIndex:optionIt];
    [option addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    return option;
}

- (CGRect)calculeFrameForOptionButtonAtIndex:(NSUInteger)optionIt
{
    CGSize sizeOfOption = [self.dataSource sizeOfOptionsInTextRawSelectorMenu:self];
    CGRect frame = CGRectMake(self.frame.origin.x + sizeOfOption.width * optionIt,
                              0,
                              sizeOfOption.width,
                              sizeOfOption.height);
    
    return frame;
}

- (NSAttributedString *)createAttributedStringForOptionAtIndex:(NSUInteger)optionIt
{
    NSString *optionStringName = [self.dataSource textRawSelectorMenu:self optionStringNameAtIndex:optionIt];
    NSDictionary *optionStringProperties = [self createPropertiesForOptionStringAtIndex:optionIt];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:optionStringName
                                                                           attributes:optionStringProperties];
    
    return attributedString;
}

- (NSDictionary *)createPropertiesForOptionStringAtIndex:(NSUInteger)optionIt
{
    UIFont *font = [UIFont fontWithName:[self.dataSource fontFamilyNameOfOptionsInTextRawSelectorMenu:self]
                                   size:[self.dataSource fontSizeOfOptionsInTextRawSelectorMenu:self]];
    CGFloat kernValue = [self.dataSource textRawSelectorMenu:self kernOfOptionsAtIndex:optionIt];
    NSDictionary *properties = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [self.dataSource colorForOptionsInTextRawSelectorMenu:self],
                                 NSKernAttributeName: [NSNumber numberWithFloat:kernValue]};
    
    return properties;
}

- (NSUInteger)createTagForButtonAtIndex:(NSUInteger)optionIt
{
    return tagBaseValue + optionIt;
}

- (NSUInteger)optionIndexFromTagOfOptionButton:(UIButton *)button
{
    return button.tag - tagBaseValue;
}

- (void)adjustFrameUsingMenuOptions
{
    NSSet *menuOptions = [self findAllMenuOptions];
    if (menuOptions.count > 0) {
        CGRect frame = CGRectInfinite;
        for (UIButton *button in menuOptions) {
            if (CGRectEqualToRect(frame, CGRectInfinite)) {
                frame = button.frame;
            } else {
                frame = CGRectMake(MIN(frame.origin.x, button.frame.origin.x),
                                   frame.origin.y,
                                   frame.size.width + button.frame.size.width,
                                   frame.size.height);
            }
        }
        
        self.frame = frame;
    }
}

- (void)changeIndicatorFromOptionIndex:(NSUInteger)currentOptionIndex toNewCurrentOptionIndex:(NSUInteger)newCurrentOptionIndex
{
    [self deactiveSelectionOnOptionIndex:currentOptionIndex];
    [self activeSelectionOnOptionIndex:newCurrentOptionIndex];
}

- (void)deactiveSelectionOnOptionIndex:(NSUInteger)optionIndex
{
    IAETextRawSelectorMenuViewSelectorType selectorType = [self.dataSource selectorTypeInTextRawSelectorMenu:self];
    UIButton *option = [self findMenuOptionWithIndex:optionIndex];
    if (selectorType == TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR) {
        option.backgroundColor = [UIColor clearColor];
    }
}

- (void)activeSelectionOnOptionIndex:(NSUInteger)optionIndex
{
    IAETextRawSelectorMenuViewSelectorType selectorType = [self.dataSource selectorTypeInTextRawSelectorMenu:self];
    UIButton *option = [self findMenuOptionWithIndex:optionIndex];
    if (selectorType == TEXTRAWMENUVIEW_SELECTOR_BACKGROUNDCOLOR) {
        UIColor *backColor = [[self.dataSource colorForSelectorIndicatorInTextRawSelectorMenu:self] copy];
        option.backgroundColor = backColor;
    }
}

- (UIButton *)findMenuOptionWithIndex:(NSUInteger)optionIndex
{
    UIButton *menuOption = nil;
    
    NSSet *options = [self findAllMenuOptions];
    for (UIButton *buttonIt in options) {
        NSUInteger indexOfButtonIt = [self optionIndexFromTagOfOptionButton:buttonIt];
        if (indexOfButtonIt == optionIndex) {
            menuOption = buttonIt;
            break;
        }
    }
    
    return menuOption;
}

#pragma mark - UIControlEvents

- (void)optionButtonPressed:(UIButton *)sender
{
    NSUInteger optionIndex = [self optionIndexFromTagOfOptionButton:sender];
    if (optionIndex != self.currentOptionIndexSelected) {
        self.currentOptionIndexSelected = optionIndex;
        [self.delegate optionIndex:optionIndex wasSelectedInTextRawSelectorMenuView:self];
    }
}

@end
