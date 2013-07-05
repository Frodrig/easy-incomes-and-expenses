//
//  IAEYearsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEAdjustConceptAmountViewControllerDelegate.h"
#import "IAECategorySelectorViewControllerDelegate.h"

@interface IAEEditModeViewController : UIViewController<UIScrollViewDelegate,
                                                        UICollectionViewDataSource,
                                                        UICollectionViewDelegate,
                                                        IAEAdjustConceptAmountViewControllerDelegate,
                                                        IAECategorySelectorViewControllerDelegate>

@end
