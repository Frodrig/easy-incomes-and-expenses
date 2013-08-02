//
//  IAEStrokeAnimatableViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEStrokeAnimatableLineView;

@protocol IAEStrokeAnimatableViewDelegate <NSObject>

@optional

- (void)strokeAnmatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView willStartToStrokeOverTheView:(UIView *)view;
- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view;

@end
