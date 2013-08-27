//
//  IAEReportAreaItemView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEReportAreaItemView : UIView

@property (nonatomic, strong) UILabel *title;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title subtitle:(NSString *)subtitle andColor:(UIColor *)color;

- (void)changeTitleLabel:(NSString *)title;

@end
