//
//  IAECategorySelectorViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 05/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECategorySelectorViewController;
@class IAECategory;

@protocol IAECategorySelectorViewControllerDelegate <NSObject>

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController didSelectCategory:(IAECategory *)category;

@end
