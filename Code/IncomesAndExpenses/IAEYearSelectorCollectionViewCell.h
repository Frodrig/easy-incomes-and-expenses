//
//  IAEYearSelectorCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEValueDecoratorView;

@interface IAEYearSelectorCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *containerForStrokeView;
@property (nonatomic) BOOL showOpenYearDecorator;
@property (nonatomic, readonly) BOOL inStrokeMode;

- (void)configureWithYearDate:(NSUInteger)yearDate balance:(NSDecimalNumber *)balance andNumberOfConcepts:(NSUInteger)numberOfConcepts;
- (void)configureWithYearDate:(NSUInteger)yearDate;

- (void)goToStrokeModeWithAnimation:(BOOL)animation;
- (void)exitFromStrokeModeWithAnimation:(BOOL)animation;

@end
