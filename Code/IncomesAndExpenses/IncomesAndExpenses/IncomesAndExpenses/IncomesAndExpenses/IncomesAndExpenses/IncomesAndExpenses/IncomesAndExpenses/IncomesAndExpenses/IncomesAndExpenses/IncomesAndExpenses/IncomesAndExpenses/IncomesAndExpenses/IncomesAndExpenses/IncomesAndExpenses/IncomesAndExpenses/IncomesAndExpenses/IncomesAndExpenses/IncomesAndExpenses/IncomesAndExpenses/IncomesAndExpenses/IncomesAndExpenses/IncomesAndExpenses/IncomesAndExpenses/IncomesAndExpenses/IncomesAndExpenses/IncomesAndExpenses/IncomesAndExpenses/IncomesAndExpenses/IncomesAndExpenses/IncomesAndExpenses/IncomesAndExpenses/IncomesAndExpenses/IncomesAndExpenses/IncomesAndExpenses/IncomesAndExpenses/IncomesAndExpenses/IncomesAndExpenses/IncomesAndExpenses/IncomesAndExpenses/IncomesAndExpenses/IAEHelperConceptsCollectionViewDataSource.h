//
//  IAEHelperConceptsCollectionViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAEEasyIncomesAndExpensesViewControllerQuery;
@class IAEEditModeConceptCollectionViewCell;

@interface IAEHelperConceptsCollectionViewDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query;

- (void)configureEditModeConceptCell:(IAEEditModeConceptCollectionViewCell *)cell withConceptAtIndexPath:(NSIndexPath *)indexPath;

@end
