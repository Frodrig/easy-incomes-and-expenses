//
//  IAEContextMenuActionSheetViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEContextMenuActionSheetViewControllerDefs.h"

@class IAEContextMenuActionSheetViewController;

@protocol IAEContextMenuActionSheetViewControllerDelegate <NSObject>

- (void)contextMenuActionSheetViewController:(IAEContextMenuActionSheetViewController *)contextMenuActionSheetViewController didSelectOption:(IAEContextMenuActionSheetOption)option;

@end
