//
//  IAESelectorContextViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAESelectorContextView;

@protocol IAESelectorContextViewDelegate <NSObject>

- (void)selectorContextView:(IAESelectorContextView *)selectorContextView didChangeToContextViewAtIndex:(NSUInteger)index;
- (void)selectorContextView:(IAESelectorContextView *)selectorContextView didSelectExportCSVOptionAtIndex:(NSUInteger)index;
- (void)selectorContextView:(IAESelectorContextView *)selectorContextView didSelectRemoveAllConceptsOptionAtIndex:(NSUInteger)index;
    
@end
