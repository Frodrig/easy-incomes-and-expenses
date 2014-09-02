//
//  IAECategoryEditorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 08/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDefs.h"

@protocol IAECategoryEditorViewControllerDelegate;

@class IAECategory;

@interface IAECategoryEditorViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic, weak)id<IAECategoryEditorViewControllerDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *conceptCellIndexPath;

- (id)initToAddCategoryOfType:(CategoryType)categoryType;
- (id)initToRenameCategory:(IAECategory *)category;

@end
