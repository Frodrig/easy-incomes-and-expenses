//
//  IAETextRawSelectorMenuViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAETextRawSelectorMenuViewDefs.h"

@class IAETextRawSelectorMenuView;

@protocol IAETextRawSelectorMenuViewDataSource <NSObject>

- (NSUInteger)numberOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (NSString *)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu optionStringNameAtIndex:(NSUInteger)optionIndex;

- (UIColor *)colorForOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (CGSize)sizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (NSString *)fontFamilyNameOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (CGFloat)fontSizeOfOptionsInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (CGFloat)textRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu kernOfOptionsAtIndex:(NSUInteger)optionIndex;

- (IAETextRawSelectorMenuViewSelectorType)selectorTypeInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;
- (UIColor *)colorForSelectorIndicatorInTextRawSelectorMenu:(IAETextRawSelectorMenuView *)textRawSelectorMenu;

@end
