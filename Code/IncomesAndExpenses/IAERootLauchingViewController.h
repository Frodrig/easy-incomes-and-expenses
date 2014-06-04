//
//  IAERootLauchingViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEEasyIncomesAndExpensesViewControllerDelegate.h"
#import "IAEHelpIndexViewControllerDelegate.h"
#import "IAEHelpCarouselViewControllerDelegate.h"

@interface IAERootLauchingViewController : UIViewController<IAEEasyIncomesAndExpensesViewControllerDelegate,
                                                            IAEHelpIndexViewControllerDelegate,
                                                            IAEHelpCarouselViewControllerDelegate>

- (void)performActionsAfterInsertedAsRootViewController;

@end
