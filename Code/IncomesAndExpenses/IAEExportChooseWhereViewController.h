//
//  IAEExportStepOneViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEEasyIncomesAndExpensesViewControllerQuery;

@interface IAEExportChooseWhereViewController : UITableViewController

@property (nonatomic, weak) NSMutableDictionary *userConfiguration;
@property(nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> query;

- (void)cancelButtonPressed:(id)sender;

@end
