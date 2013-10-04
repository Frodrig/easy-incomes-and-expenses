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
@protocol IAEReportAreaViewDelegate;

// Nota: IAEReportAreaView hereda de UIScrollView y es delegado de si mismo para gestionar FX al hacer scroll
@interface IAEReportAreaView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<IAEReportAreaViewDataSource> dataSource;

// Nota: IMPORTANTE esta clase es delegada de si misma para poder capturar eventos de UIScrollView. Es por ello que creamos un delegado a parte
// para comunicar al exterior los eventos propios de esta clase. NO USAR .delegate desde fuera de esta clase
@property (nonatomic, weak) id<IAEReportAreaViewDelegate> reportAreaViewDelegate;

@property (nonatomic, readonly) BOOL reloadInProgress;

- (void)reloadDataWithAnimation:(BOOL)animation;
- (void)releaseData;

- (void)playShowAnimationOverActualLoadedData;

- (BOOL)existChangeTitleInProgressOnReportAreaItems;

@end
