//
//  NSUserDefaults+EasyIncAndExp.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (EasyIncAndExp)

- (BOOL)isTotalAmountModeInReportSection;
- (BOOL)isTotalPercentageModeInReportSection;
- (void)changeToNextReportMode;
- (void)changeToReportTotalAmountModeInReportSection;
- (void)changeToReportTotalPercentageModeInReportSection;

@end
