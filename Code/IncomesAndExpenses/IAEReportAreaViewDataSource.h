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

- (NSUInteger)numberOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView;
- (CGFloat)maxValueOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView;
- (UIColor *)colorRepresentationOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView;

- (CGFloat)reportAreaView:(IAEReportAreaView *)reportAreaView valueOfItemWithIndex:(NSUInteger)itemIndex;
- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView titleOfItemWithIndex:(NSUInteger)itemIndex;
- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView subtitleOfItemWithIndex:(NSUInteger)itemIndex;

@end
