//
//  IAENewYearDatePickerlViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAENewYearDatePickerDelegate.h"

@interface IAENewYearDatePickerViewController : UIViewController

@property(nonatomic, weak) id<IAENewYearDatePickerDelegate> delegate;

@end
