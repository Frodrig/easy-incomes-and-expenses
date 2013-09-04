//
//  IAEDayCalendarSelectorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEDayCalendarSelectorViewControllerDelegate;

@interface IAEDayCalendarSelectorViewController : UIViewController

@property(nonatomic, weak)id<IAEDayCalendarSelectorViewControllerDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *conceptCellIndexPath;

- (instancetype)initWithYearDate:(NSUInteger)yearDate monthIndex:(NSUInteger)monthIndex andDaySelected:(NSUInteger)daySelected;

@end
