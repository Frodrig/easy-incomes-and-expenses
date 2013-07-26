//
//  IAETextRawSelectorMenuView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAETextRawSelectorMenuViewDelegate;
@protocol IAETextRawSelectorMenuViewDataSource;

@interface IAETextRawSelectorMenuView : UIView

@property (nonatomic, weak) id<IAETextRawSelectorMenuViewDelegate> delegate;
@property (nonatomic, weak) id<IAETextRawSelectorMenuViewDataSource> dataSource;

- (void) reloadData;

@end
