//
//  IAEReportAreaView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEReportAreaViewDelegate;
@protocol IAEReportAreaViewDataSource;

@interface IAEReportAreaView : UIScrollView

@property (nonatomic, weak) id<IAEReportAreaViewDelegate> reportDelegate;
@property (nonatomic, weak) id<IAEReportAreaViewDataSource> dataSource;

- (void)reloadData;

@end
