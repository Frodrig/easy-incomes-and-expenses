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

// Nota: IAEReportAreaView hereda de UIScrollView y es delegado de si mismo para gestionar FX al hacer scroll
@interface IAEReportAreaView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<IAEReportAreaViewDataSource> dataSource;

- (void)reloadDataWithAnimation:(BOOL)animation;
- (void)releaseData;

- (void)playShowAnimationOverActualLoadedData;

@end
