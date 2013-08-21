//
//  IAEYearsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEStrokeAnimatableViewDelegate.h"

@protocol IAEYearSelectorViewControllerDelegate;

@interface IAEYearSelectorViewController : UIViewController<UICollectionViewDataSource,
                                                            UICollectionViewDelegate,
                                                            IAEStrokeAnimatableViewDelegate>

@property (nonatomic, weak) id<IAEYearSelectorViewControllerDelegate> delegate;

- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)yearSegmentedControlPressed:(id)sender;

@end
