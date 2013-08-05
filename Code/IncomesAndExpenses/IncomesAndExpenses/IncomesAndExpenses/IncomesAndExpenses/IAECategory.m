//
//  IAECategory.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategory.h"
#import "IAEConcept.h"
#import "IAEBook.h"

@interface IAECategory (PrimitiveAccessors)
- (void)setPrimitiveTag:(NSString *)newtag;
@end

@implementation IAECategory

@dynamic categoryType;
@dynamic tag;

static NSString * const kLTextGeneralIncome = @"General Income";
static NSString * const kLTextGeneralExpense = @"General Expense";
static NSString * const kLTextIncomeCategoryType = @"Income";
static NSString * const kLTextExpenseCategoryType = @"Expense";

// Notas:
// - No vacio
// - Con al menos un caracter distinto que espacio
// - No existe otra categoria con el mismo nombre
+ (ValidTagCheckResult)isAValidTag:(NSString *)tag
{
    NSString *tagTrimming = nil;
    
    ValidTagCheckResult result = tag.length > 0 ? ValidTag : InvalidEmptyTag;
    if (result == ValidTag) {
        tagTrimming = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        result = tagTrimming.length == 0 ? InvalidWhiteSpaceOnlyTag : ValidTag;
    }
    
    if (result == ValidTag) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:@"IAECategory"];
        NSError *error = nil;
        NSArray *fetchRequest = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
        if (error != nil) {
            [NSException raise:@"IAECategoryStore: Failed searching all categories " format:@"cause :%@", error];
        } else {
            NSUInteger indexOfObject = [fetchRequest indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                IAECategory *category = obj;
                *stop = NSOrderedSame == [category.tag caseInsensitiveCompare:tagTrimming];
                if (!*stop) {
                    *stop = NSOrderedSame == [[category localizedTag] caseInsensitiveCompare:tagTrimming];
                }
                
                return *stop;
            }];
            
            result = indexOfObject == NSNotFound ? ValidTag : InvalidEqualToAnotherTag;
        }
    }
    
    return result;
}

// Devuelve el tag pasando antes por la tabla de strings traducibles si resulta que es una generica
- (NSString *)localizedTag
{
    NSString *retTag = self.tag;
    if ([self.tag compare:kLTextGeneralIncome] == NSOrderedSame) {
        retTag = NSLocalizedString(kLTextGeneralIncome, @"");
    } else if ([self.tag compare:kLTextGeneralExpense] == NSOrderedSame) {
        retTag = NSLocalizedString(kLTextGeneralExpense, @"");
    }
    
    return retTag;
}

// Nota: Necesario desacoplar porque en la creacion de los objetos se coge de la BD los tags y en el chequeo al comprobar
// encontramso que efectivamente hay un tag como el que queremos poner.
- (BOOL)setTagWithValidityCheck:(NSString *)tag
{
    BOOL setOk = [IAECategory isAValidTag:tag];
    if (setOk) {
        self.tag = tag;
    }
    
    return setOk;
}

- (NSString *)description
{
    return self.tag;
}

- (BOOL)isIncomeCategory
{
    return self.categoryType == IncomeCategory;
}

- (BOOL)isExpenseCategory
{
    return self.categoryType == ExpenseCategory;
}

- (NSString *)localizedCategoryTypeString
{
    return self.categoryType == IncomeCategory ? NSLocalizedString(kLTextIncomeCategoryType, @"") :
                                                 NSLocalizedString(kLTextExpenseCategoryType, @"");
}

@end
