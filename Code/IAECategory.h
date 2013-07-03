//
//  IAECategory.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CategoryDefs.h"

@class IAEConcept;

@interface IAECategory : NSManagedObject

@property (nonatomic) int16_t categoryType;
@property (nonatomic, retain) NSString *tag;
@end

@interface IAECategory (CoreDataGeneratedAccessors)

+ (ValidTagCheckResult)isAValidTag:(NSString *)tag;

- (BOOL)setTagWithValidityCheck:(NSString *)tag;

- (NSString *)localizedTag;

- (void)addConceptObject:(IAEConcept *)value;
- (void)removeConceptObject:(IAEConcept *)value;

- (BOOL)isIncomeCategory;
- (BOOL)isExpenseCategory;

- (NSString *)description;


@end
