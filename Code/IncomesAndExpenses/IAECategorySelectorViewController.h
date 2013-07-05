//
//  IAECategorySelectorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAECategorySelectorViewControllerDelegate;

@interface IAECategorySelectorViewController : UIViewController<UITableViewDataSource,
                                                                UITableViewDelegate>

@property(nonatomic, weak)id<IAECategorySelectorViewControllerDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *conceptCellIndexPath;

@end
