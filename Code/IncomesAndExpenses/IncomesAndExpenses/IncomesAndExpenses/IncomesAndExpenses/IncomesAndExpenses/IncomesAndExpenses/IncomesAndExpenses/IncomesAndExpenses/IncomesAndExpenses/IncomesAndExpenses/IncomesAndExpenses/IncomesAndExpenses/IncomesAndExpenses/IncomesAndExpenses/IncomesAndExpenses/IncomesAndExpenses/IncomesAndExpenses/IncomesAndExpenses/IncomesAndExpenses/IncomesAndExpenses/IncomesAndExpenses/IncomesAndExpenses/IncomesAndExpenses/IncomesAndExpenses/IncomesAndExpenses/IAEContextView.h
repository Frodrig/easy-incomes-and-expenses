//
//  IAEContextView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEContextViewDefs.h"

@protocol IAEContextViewDataSource;

@interface IAEContextView : UIView

@property (nonatomic, weak) id<IAEContextViewDataSource> dataSource;

@property(nonatomic, readonly) NSUInteger valueIndex;
@property(nonatomic, readonly) IAEContextViewType contextType;

- (id)initWithFrame:(CGRect)frame type:(IAEContextViewType)contextViewType andValueIndex:(NSUInteger)valueIndex;

- (void)reloadDataWithAnimation:(BOOL)animation;


@end
