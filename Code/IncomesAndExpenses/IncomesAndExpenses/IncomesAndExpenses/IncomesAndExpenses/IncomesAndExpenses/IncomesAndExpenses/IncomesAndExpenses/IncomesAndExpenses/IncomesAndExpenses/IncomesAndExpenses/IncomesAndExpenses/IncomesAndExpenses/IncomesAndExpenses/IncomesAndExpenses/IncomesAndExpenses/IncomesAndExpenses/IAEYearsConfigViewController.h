//
//  IAEYearsConfigViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAENewYearDatePickerDelegate.h"
#import "IAEYearsConfigViewControllerDelegate.h"

@interface IAEYearsConfigViewController : UIViewController<IAENewYearDatePickerDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) id<IAEYearsConfigViewControllerDelegate> delegate;

- (id)initWithActualYear:(IAEYear *)year;

@end
