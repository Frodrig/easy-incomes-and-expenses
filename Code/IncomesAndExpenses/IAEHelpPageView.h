//
//  IAEHelpPageView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEHelpPageView : UIView

- (instancetype)initWithFrame:(CGRect)frame andTexts:(NSArray *)text;

- (void)setTextLabelsWithAlpha:(CGFloat)alpha;

@end
