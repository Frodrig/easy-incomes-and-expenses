//
//  IAEYearsConfigViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 22/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEYear;

@protocol IAEYearsConfigViewControllerDelegate <NSObject>

- (void)newActualYearSelected:(IAEYear *)year;

@end
