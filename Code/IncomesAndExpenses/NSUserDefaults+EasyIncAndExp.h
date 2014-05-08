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

- (BOOL)isTotalAmountModeInReportSection;
- (BOOL)isTotalPercentageModeInReportSection;
- (void)changeToNextReportMode;
- (void)changeToReportTotalAmountModeInReportSection;
- (void)changeToReportTotalPercentageModeInReportSection;

- (BOOL)isDayModeActiveForConcepts;
- (void)changeDayModeActiveForConcepts;

- (void)changeInitialMonthTo:(MonthType)startMonth;
- (MonthType)actualInitialMonth;

- (BOOL)isRemoveConceptConfirmationActive;
- (void)changeRemoveConceptConfirmation;

- (BOOL)isPasswordRecoveryEmailSet;
- (NSString *)findPasswordRecoveryEmail;
- (void)vinculePasswordRecoveryEmail:(NSString *)passwordRecoveryEmail;
- (void)desvinculePasswordRecoveryEmail;

- (BOOL)isFixRemoveCategoryActionLostInUnloadedYearsExecuted;
- (BOOL)isFixRemoveCategoryActionLostInUnloadedYearsNotExecuted;
- (void)setFixRemoveCategoryActionLostInUnloadedYearsExecuted:(BOOL)executed;

- (BOOL)isProVersionActive;
- (void)enableProVersion;
- (void)disableProVersion;

@end
