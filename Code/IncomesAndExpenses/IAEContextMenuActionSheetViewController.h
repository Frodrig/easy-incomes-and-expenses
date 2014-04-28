//
//  IAEContextMenuActionSheetViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEContextMenuActionSheetViewControllerDelegate.h"
#import "IAEContextMenuActionSheetViewControllerDefs.h"

@interface IAEContextMenuActionSheetViewController : UIViewController

@property (nonatomic, weak) id<IAEContextMenuActionSheetViewControllerDelegate> delegate;

- (instancetype)initWithOptionsEnabled;
- (instancetype)initWithOptionsDisabled;
- (instancetype)initWithEnabledOption:(IAEContextMenuActionSheetOption)enabledOption;

@end
