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

@implementation IAEFixRemoveCategoryActionLostInUnloadedYears

+ (void)checkAndExecuteIfApplicable
{
    NSMutableString *documentWithFixes = [[NSMutableString alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] isFixRemoveCategoryActionLostInUnloadedYearsNotExecuted]) {
        [[IAEBook sharedBook] loadAll];
        
        for (IAEYear *yearObjIt in [IAEBook sharedBook].years) {
            for (IAEMonth *monthObjIt in yearObjIt.months) {
                for (IAEConcept *conceptObjIt in monthObjIt.concepts) {
                    if (![[IAEBook sharedBook].context existingObjectWithID:conceptObjIt.category.objectID error:NULL]) {
                        conceptObjIt.category = [IAECategoryStore sharedCategoryStore].generalExpenseCategory;
                        
                        [documentWithFixes appendString:@"Category Lost and fixed as income - "];
                        [documentWithFixes appendString:[NSString stringWithFormat:@"Year: %@ ", yearObjIt.yearDateAsString]];
                        [documentWithFixes appendString:[NSString stringWithFormat:@"Month: %@ ", monthObjIt.monthAsString]];
                        [documentWithFixes appendString:[NSString stringWithFormat:@"Ammount: %@ ", conceptObjIt.amount]];
                        if ([[NSUserDefaults standardUserDefaults] isDayModeActiveForConcepts]) {
                            [documentWithFixes appendString:[NSString stringWithFormat:@"Day: %d", conceptObjIt.dayOfTheMonth]];
                        }
                    }
                }
            }
         }
        
        [[IAEBook sharedBook] saveAll];
        [[IAEBook sharedBook] unloadAll];
        
        [[NSUserDefaults standardUserDefaults] setFixRemoveCategoryActionLostInUnloadedYearsExecuted:YES];
    }
}

@end
