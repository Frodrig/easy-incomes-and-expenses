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

// OJO esto deberia de ser una propiedad readonly para que desde fuera no se pueda modificar el array
// IMPORTATE: Las categorias de usuario siempre se mantinen ordenadas alfabeticamente
@property (nonatomic, strong, readonly) NSMutableArray *userDefinedCategories;

+ (IAECategoryStore *)sharedCategoryStore;

- (IAECategory *)generalIncomeCategory;
- (IAECategory *)generalExpenseCategory;

- (IAECategory *)createCategoryOfType:(CategoryType)type andTag:(NSString *)tag withValidityTagCheck:(BOOL)validity;

- (void)removeCategoryByTag:(NSString *)tag;
- (void)removeCategory:(IAECategory *)category;

- (IAECategory *)findCategoryByTag:(NSString *)tag;

- (NSArray *)allUserCategoriesOfType:(CategoryType)type;
- (NSArray *)generalCategoryAndAllUserCategoriesOfType:(CategoryType)type;

@end
