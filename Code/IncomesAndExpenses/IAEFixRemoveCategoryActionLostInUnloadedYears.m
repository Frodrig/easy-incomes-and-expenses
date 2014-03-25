//
//  IAEFixRemoveCategoryActionLostInUnloadedYears.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 17/03/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEFixRemoveCategoryActionLostInUnloadedYears.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEBook.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "IAEConcept.h"
#import "IAEYear.h"
#import "IAEMonth.h"

static const NSString * const kMinVersion = @"2.4.3";

@interface IAEFixRemoveCategoryActionLostInUnloadedYears()

@end

@implementation IAEFixRemoveCategoryActionLostInUnloadedYears

+ (IAEFixRemoveCategoryActionLostInUnloadedYears *)defaultFix
{
    static IAEFixRemoveCategoryActionLostInUnloadedYears *defaultFix = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultFix = [[self alloc] init];
    });
    
    return defaultFix;
}

- (void)checkAndExecuteIfApplicable
{
    [[NSUserDefaults standardUserDefaults] setFixRemoveCategoryActionLostInUnloadedYearsExecuted:NO];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableString *documentWithFixes = [[NSMutableString alloc] init];
    
    if ([self canExecuteFix]) {
        [[IAEBook sharedBook] loadAll];
        
        for (IAEYear *yearObjIt in [IAEBook sharedBook].years) {
            for (IAEMonth *monthObjIt in yearObjIt.months) {
                for (IAEConcept *conceptObjIt in monthObjIt.concepts) {
                    const BOOL conceptWithCategoryToFix = ![[IAEBook sharedBook].context existingObjectWithID:conceptObjIt.category.objectID error:NULL];
                    if (conceptWithCategoryToFix) {
                        conceptObjIt.category = [IAECategoryStore sharedCategoryStore].generalExpenseCategory;
                        [documentWithFixes appendString:[self createDescriptionOfConceptFixed:conceptObjIt]];
                    }
                }
            }
         }
        
        [[IAEBook sharedBook] saveAll];
        [[IAEBook sharedBook] unloadAll];
        
        [[NSUserDefaults standardUserDefaults] setFixRemoveCategoryActionLostInUnloadedYearsExecuted:YES];
        
        self.resultReport = [documentWithFixes mutableCopy];
    }
}

- (BOOL)canExecuteFix
{
    const BOOL isFixNotExecuted = [[NSUserDefaults standardUserDefaults] isFixRemoveCategoryActionLostInUnloadedYearsNotExecuted];
    
    return isFixNotExecuted;
}

- (NSString *)createDescriptionOfConceptFixed:(IAEConcept *)concept
{
    NSMutableString *documentWithFixes = [[NSMutableString alloc] init];

    [documentWithFixes appendString:[NSString stringWithFormat:@"%@: %@ ", NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.year", @""), concept.month.year.yearDateAsString]];
    [documentWithFixes appendString:[NSString stringWithFormat:@"%@: %@ ", NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.month", @""), concept.month.monthAsString]];
    [documentWithFixes appendString:[NSString stringWithFormat:@"%@: %@ ", NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.amount", @""), concept.amount]];
    if ([[NSUserDefaults standardUserDefaults] isDayModeActiveForConcepts]) {
        [documentWithFixes appendString:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"IAEFixRemoveCategoryActionLostInUnloadedYears.day", @""), concept.dayOfTheMonth]];
    }
    
    [documentWithFixes appendString:@"\n"];

    return documentWithFixes;
}

@end
