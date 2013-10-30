//
//  IAEHelpConfigureStartMonthSelectorTableViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 30/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEHelpIndexViewControllerDelegate;

@interface IAEHelpConfigureStartMonthSelectorTableViewController : UITableViewController

@property (nonatomic, weak)id<IAEHelpIndexViewControllerDelegate> delegate;

@end
