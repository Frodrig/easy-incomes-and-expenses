//
//  IAECategoryStore.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 24/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryDefs.h"

@class IAECategory;


@interface IAECategoryStore : NSObject

// Nota: Las categorias de usuario siempre se mantienen ordenadas alfabeticamente
@property (nonatomic, strong, readonly) NSMutableArray *userDefinedCategories;
@property (nonatomic, strong, readonly) IAECategory *generalIncomeCategory;
@property (nonatomic, strong, readonly) IAECategory *generalExpenseCategory;

+ (IAECategoryStore *)sharedCategoryStore;

- (IAECategory *)createCategoryOfType:(CategoryType)type andTag:(NSString *)tag withValidityTagCheck:(BOOL)validity;

- (void)removeCategoryByTag:(NSString *)tag;
- (void)removeCategory:(IAECategory *)category;

- (IAECategory *)findCategoryByTag:(NSString *)tag;
- (NSArray *)allUserCategoriesOfType:(CategoryType)type;
- (NSArray *)generalCategoryAndAllUserCategoriesOfType:(CategoryType)type;

- (BOOL)isGeneralCategory:(IAECategory *)category;

@end
