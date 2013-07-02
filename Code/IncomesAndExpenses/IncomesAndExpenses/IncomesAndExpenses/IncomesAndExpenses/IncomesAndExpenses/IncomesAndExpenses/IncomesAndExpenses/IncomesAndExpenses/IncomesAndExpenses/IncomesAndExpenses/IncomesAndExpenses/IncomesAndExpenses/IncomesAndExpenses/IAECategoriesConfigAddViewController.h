//
//  IAECategoriesConfigAddViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDefs.h"

@class IAECategory;

@interface IAECategoriesConfigAddViewController : UIViewController

- (id)initWithCategoryType:(CategoryType)categoryType andRenamingCategory:(IAECategory *)category fromInputPanel:(BOOL)fromInputPanel;

@end
