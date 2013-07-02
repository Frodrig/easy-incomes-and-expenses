//
//  IAEInputConceptsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEInputConceptsDelegate.h"
#import "IAEInputConceptsDataSource.h"

@class IAEMonth;

@interface IAEInputConceptsViewController : UIViewController<UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<IAEInputConceptsDelegate> delegate;
@property (nonatomic, weak) id<IAEInputConceptsDataSource> dataSource;

- (void)updateStarAndEndFrame;
- (CGSize)sizeOfDragToolbarView;

@end
