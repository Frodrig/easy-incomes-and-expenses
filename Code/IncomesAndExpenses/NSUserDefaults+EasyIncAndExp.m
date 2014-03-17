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

static NSString * const kUserDefaultsReportAmountMode = @"reportAmountMode";
static NSString * const kUserDefaultsReportAmountModeTotalAmountValue = @"totalAmounts";
static NSString * const kUserDefaultsReportAmountModePercentageAmountValue = @"percentageAmounts";
static NSString * const kFixRemoveCategoryActionLostInUnloadedYearsExecuted = @"fixRemoveCategoryActionLostInUnloadedYearsExecuted";
static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

#pragma mark - ReportSection

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
    NSString *actualAmountMode = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsReportAmountMode];
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
    
    [[NSUserDefaults standardUserDefaults] setValue:reportAmountModeType forKey:kUserDefaultsReportAmountMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isDayModeActiveForConcepts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

- (BOOL)isFixRemoveCategoryActionLostInUnloadedYearsNotExecuted
{
    return ![self isFixRemoveCategoryActionLostInUnloadedYearsExecuted];
}

- (BOOL)isFixRemoveCategoryActionLostInUnloadedYearsExecuted
{
    const BOOL fixExecuted = [[NSUserDefaults standardUserDefaults] boolForKey:kFixRemoveCategoryActionLostInUnloadedYearsExecuted];
    
    return fixExecuted;
}

- (void)setFixRemoveCategoryActionLostInUnloadedYearsExecuted:(BOOL)executed
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:executed] forKey:kFixRemoveCategoryActionLostInUnloadedYearsExecuted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
