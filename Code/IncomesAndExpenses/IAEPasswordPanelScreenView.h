//
//  IAEPasswordPanelScreenView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEPasswordPanelScreenView : UIView

- (void)setMessage:(NSString *)message;

- (void)addCodeAtPosition:(NSInteger)position;
- (void)clearCodeAtPosition:(NSInteger)position;

@end
