//
//  IAETextRawSelectorMenuView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAETextRawSelectorMenuViewDelegate;
@protocol IAETextRawSelectorMenuViewDataSource;


typedef NS_ENUM(NSUInteger, TextRawSelectorAnimationType) {
  TextRawSelectorAnimation_Blink,
  TextRawSelectorAnimation_Rotation,
  TextRawSelectorAnimation_DestroyWithGosthAndReload,
};

@interface IAETextRawSelectorMenuView : UIView

@property (nonatomic, weak) id<IAETextRawSelectorMenuViewDelegate> delegate;
@property (nonatomic, weak) id<IAETextRawSelectorMenuViewDataSource> dataSource;

@property (nonatomic) NSUInteger currentOptionIndexSelected;
@property (nonatomic) BOOL optionsEnabled;

- (void)reloadData;
- (void)reloadOptionsStringNames;
- (void)reloadOptionStringNameAtIndex:(NSUInteger)index;

- (void)changeToOptionIndex:(NSUInteger)index;

- (void)animateOptionAtIndex:(NSUInteger)index withAnimationType:(TextRawSelectorAnimationType)animationType;

- (CGRect)rectOfOptionAtIndex:(NSUInteger)index;

@end
