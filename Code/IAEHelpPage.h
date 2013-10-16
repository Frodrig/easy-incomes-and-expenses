//
//  IAEHelpPage.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEHelpPage : NSObject

@property (nonatomic, strong, readonly) NSArray *texts;
@property (nonatomic, readonly) NSUInteger themeIndex;
@property (nonatomic, readonly) NSUInteger pageIndex;

- (instancetype)initWithThemeIndex:(NSUInteger)themeIndex andPageIndex:(NSUInteger)pageIndex;

- (void)description;

@end
