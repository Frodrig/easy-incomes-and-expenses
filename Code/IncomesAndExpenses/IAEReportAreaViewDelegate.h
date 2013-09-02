//
//  IAEReportAreaViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEReportAreaView;

@protocol IAEReportAreaViewDelegate <NSObject>

- (void)reloadDataWithAnimationWasDoneInReportAreaView:(IAEReportAreaView *)reportAreaView;

@end
