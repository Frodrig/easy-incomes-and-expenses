//
//  IAEAdjustConceptAmountViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEAdjustConceptAmountViewControllerDelegate;

@interface IAEAdjustConceptAmountViewController : UIViewController

@property(nonatomic, weak)id<IAEAdjustConceptAmountViewControllerDelegate> delegate;
@property(nonatomic, strong)NSIndexPath *conceptCellIndexPath;

@end
