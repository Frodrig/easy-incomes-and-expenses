//
//  IAEAmountStepperViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 25/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEAmountStepperViewControllerDelegate.h"

@interface IAEAmountStepperViewController : UIViewController

@property (nonatomic, weak) id<IAEAmountStepperViewControllerDelegate> delegate;

@end
