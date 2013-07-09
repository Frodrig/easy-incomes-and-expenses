//
//  IAECategorySelectorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAECategorySelectorViewControllerDelegate;

typedef NS_ENUM(NSUInteger, CategorySelectorActionFlags) {
    CATEGORYSELECTOR_EXTRAACTION_ADD = 0x0001,
    CATEGORYSELECTOR_EXTRAACTION_RENAME = 0x0001 << 1,
    CATEGORYSELECTOR_EXTRAACTION_DELETE = 0x0001 << 2,
    CATEGORYSELECTOR_EXTRAACTION_DONE = 0x0001 << 3,
    CATEGORYSELECTOR_EXTRAACTION_ALL_ACTIONS = 0xFFFF
};

@interface IAECategorySelectorViewController : UIViewController<UITableViewDataSource,
                                                                UITableViewDelegate>

@property(nonatomic, weak)id<IAECategorySelectorViewControllerDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *conceptCellIndexPath;

- (id)init;
- (id)initWithExtraActions:(NSUInteger)actions;
- (id)initWithAllExtraActions;

@end
