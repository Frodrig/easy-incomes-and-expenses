//
//  IAEContextSubmenuView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEContextSubmenuViewDelegate.h"
#import "IAEContextSubmenuViewDatasource.h"

@interface IAEContextSubmenuView : UIView

@property (nonatomic, weak) id<IAEContextSubmenuViewDelegate> delegate;
@property (nonatomic, weak) id<IAEContextSubmenuViewDatasource> datasource;

@end
