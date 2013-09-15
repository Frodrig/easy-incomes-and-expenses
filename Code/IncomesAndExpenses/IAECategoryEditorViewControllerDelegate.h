//
//  IAECategoryEditorViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 08/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECategoryEditorViewController;

@protocol IAECategoryEditorViewControllerDelegate <NSObject>

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
             didCancelRenameCategory:(IAECategory *)category;

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateNewCategoryTag:(NSString *)categoryTag
                      ofCategoryType:(CategoryType)categoryType;

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateRenameCategory:(IAECategory *)category
                             withTag:(NSString *)tag;

@end
