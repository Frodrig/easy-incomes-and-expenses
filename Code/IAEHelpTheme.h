//
//  IAEHelpTheme.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEHelpTheme : NSObject

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) NSUInteger themeIndex;
@property (nonatomic, strong, readonly) NSArray *helpPages;

- (instancetype)initWithThemeIndex:(NSUInteger)themeIndex;

- (void)description;

@end
