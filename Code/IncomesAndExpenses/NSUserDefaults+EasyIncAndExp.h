//
//  NSUserDefaults+EasyIncAndExp.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthDefs.h"

@interface NSUserDefaults (EasyIncAndExp)

- (void)prepareDefaults;

- (BOOL)isDayModeActive;

- (BOOL)isTotalAmountModeInReportSection;
- (BOOL)isTotalPercentageModeInReportSection;
- (void)changeToNextReportMode;
- (void)changeToReportTotalAmountModeInReportSection;
- (void)changeToReportTotalPercentageModeInReportSection;

- (void)changeInitialMonthTo:(MonthType)startMonth;
- (MonthType)actualInitialMonth;

- (NSString *)findPassword;
- (void)clearPassword;
- (void)setNewPassword:(NSString *)password;
- (BOOL)isPasswordActivated;

@end
