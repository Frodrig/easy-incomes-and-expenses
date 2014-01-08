//
//  IAEFavoriteConceptsViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEFavoriteConceptsViewController;

@protocol IAEFavoriteConceptsViewControllerDelegate <NSObject>

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
didPressedAddOptionWithFavoriteIncomes:(NSArray *)incomes
                           andExpenses:(NSArray *)expenses;

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
        willRemoveFavoriteWithCategory:(NSString *)category
                              andValue:(NSString *)value;
- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
         didRemoveFavoriteWithCategory:(NSString *)category
                              andValue:(NSString *)value;

@end
