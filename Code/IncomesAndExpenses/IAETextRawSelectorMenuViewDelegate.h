//
//  IAETextRawSelectorMenuViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAETextRawSelectorMenuView;

@protocol IAETextRawSelectorMenuViewDelegate <NSObject>

@optional

- (void)optionIndex:(NSUInteger)optionIndex wasSelectedInTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenuView;
- (BOOL)canSelectOptionIndex:(NSUInteger)optionIndex inTextRawSelectorMenuView:(IAETextRawSelectorMenuView *)textRawSelectorMenuView;

@end
