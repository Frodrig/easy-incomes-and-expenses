//
//  NSUserDefaults+EasyIncAndExp.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "NSUserDefaults+EasyIncAndExp.h"
#import "Flurry.h"

@implementation NSUserDefaults (EasyIncAndExp)

#pragma mark - Constants

static NSString * const kUserDefaultsDayModeActiveKey = @"dayModeActive";
static NSString * const kUserDefaultsReportAmountModeKey = @"reportAmountMode";
static NSString * const kUserDefaultInitialMonthKey = @"initialMonth";
static NSString * const kUserDefaultPasswordKey = @"password";

static NSString * const kUserDefaultsReportAmountModeTotalAmountValue = @"totalAmounts";
static NSString * const kUserDefaultsReportAmountModePercentageAmountValue = @"percentageAmounts";

#pragma mark - Prepare

- (void)prepareDefaults
{
    NSDictionary *defaults = @{ kUserDefaultsDayModeActiveKey: [NSNumber numberWithBool:NO],
                                kUserDefaultsReportAmountModeKey: kUserDefaultsReportAmountModeTotalAmountValue,
                                kUserDefaultInitialMonthKey: @(January),
                                kUserDefaultPasswordKey: @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];    
}

#pragma mark - ReportSection

- (BOOL)isDayModeActive
{
    const BOOL isDayModeActive = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActiveKey];
    
    return isDayModeActive;
}

- (BOOL)isTotalAmountModeInReportSection
{
    const BOOL isTotalAmountMode = [self isReportAmountModeInReportSectionOfType:kUserDefaultsReportAmountModeTotalAmountValue];
    
    return isTotalAmountMode;
}

- (BOOL)isTotalPercentageModeInReportSection
{
    const BOOL isPercentageAmountMode = [self isReportAmountModeInReportSectionOfType:kUserDefaultsReportAmountModePercentageAmountValue];
    
    return isPercentageAmountMode;
}

- (BOOL)isReportAmountModeInReportSectionOfType:(NSString *)reportAmountModeType
{
    NSString *actualAmountMode = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsReportAmountModeKey];
    const BOOL isTheSameMode = [actualAmountMode compare:reportAmountModeType] == NSOrderedSame;
    
    return isTheSameMode;
}

- (void)changeToNextReportMode
{
    if ([self isTotalAmountModeInReportSection]) {
        [self changeToReportTotalPercentageModeInReportSection];
    } else if ([self isTotalPercentageModeInReportSection]) {
        [self changeToReportTotalAmountModeInReportSection];
    }
}

- (void)changeToReportTotalAmountModeInReportSection
{
    if (![self isTotalAmountModeInReportSection]) {
        [self changeToReportAmountModeInReportSectionOfType:kUserDefaultsReportAmountModeTotalAmountValue];
    }
}

- (void)changeToReportTotalPercentageModeInReportSection
{
    if (![self isTotalPercentageModeInReportSection]) {
        [self changeToReportAmountModeInReportSectionOfType:kUserDefaultsReportAmountModePercentageAmountValue];
    }
}

- (void)changeToReportAmountModeInReportSectionOfType:(NSString *)reportAmountModeType
{
    [Flurry logEvent:@"report_changemode" withParameters:@{@"mode" :reportAmountModeType}];
    
    [[NSUserDefaults standardUserDefaults] setValue:reportAmountModeType forKey:kUserDefaultsReportAmountModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Initial Month

- (void)changeInitialMonthTo:(MonthType)startMonth
{
    NSAssert(startMonth != InvalidMonth, @"");
    [Flurry logEvent:@"initalmonth_change" withParameters:@{@"month" : @(startMonth)}];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(startMonth) forKey:kUserDefaultInitialMonthKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MonthType)actualInitialMonth
{
    NSNumber *startMonth = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultInitialMonthKey];
    
    return startMonth.integerValue;
}

@end
