//
//  IAEHelpViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEHelpIndexViewControllerDelegate;

@interface IAEHelpViewController : UITableViewController

@property (nonatomic, weak)id<IAEHelpIndexViewControllerDelegate> delegate;

@end
