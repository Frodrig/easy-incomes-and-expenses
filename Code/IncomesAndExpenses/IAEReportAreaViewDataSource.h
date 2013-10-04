//
//  IAEReportAreaViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEReportAreaView;

@protocol IAEReportAreaViewDataSource

- (BOOL)canChangeActualReportAmountModeInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (BOOL)showNoItemsLabelIfAppropiateInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (NSUInteger)numberOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView;
- (CGFloat)maxValueOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (void)reloadAllItemsWillBeginInReportAreaView:(IAEReportAreaView *)reportAreaView;
- (void)reloadAllItemsDidEndInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (void)changeActualReportAmountModeWillOcurrInReportAreaView:(IAEReportAreaView *)reportAreaView;
- (void)changeActualReportAmountModeDidOcurrInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (UIColor *)reportAreaView:(IAEReportAreaView *)reportAreaView colorRepresentationOfItemWithIndex:(NSUInteger)itemIndex;
- (CGFloat)reportAreaView:(IAEReportAreaView *)reportAreaView valueOfItemWithIndex:(NSUInteger)itemIndex;
- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView titleOfItemWithIndex:(NSUInteger)itemIndex;
- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView subtitleOfItemWithIndex:(NSUInteger)itemIndex;

@end
