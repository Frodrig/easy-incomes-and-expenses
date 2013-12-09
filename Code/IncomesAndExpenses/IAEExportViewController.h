//
//  IAEExportViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEEasyIncomesAndExpensesViewControllerQuery;

@interface IAEExportViewController : UINavigationController

@property(nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> query;

@end
