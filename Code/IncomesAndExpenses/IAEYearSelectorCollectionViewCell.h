//
//  IAEYearSelectorCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEValueDecoratorView;

@interface IAEYearSelectorCollectionViewCell : UICollectionViewCell

- (void)configureWithYearDate:(NSUInteger)yearDate andBalance:(NSDecimalNumber *)balance;
- (void)configureWithYearDate:(NSUInteger)yearDate;

@end
