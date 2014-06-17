//
//  IAEHelperConceptsCollectionViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEEasyIncomesAndExpensesQuery;
@class IAEEditModeConceptCollectionViewCell;

@interface IAEHelperConceptsCollectionViewDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(IAEEasyIncomesAndExpensesQuery *)query;

- (void)configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:(NSIndexPath *)indexPath;

@end
