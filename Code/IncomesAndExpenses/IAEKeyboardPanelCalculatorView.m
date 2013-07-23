//
//  IAEKeyboardPanel.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEKeyboardPanelCalculatorView.h"
#import "IAECurrencyManager.h"

@interface IAEKeyboardPanelCalculatorView()

@property (nonatomic, weak) UIButton *decimalButton;

@end

@implementation IAEKeyboardPanelCalculatorView

static NSUInteger tagDecimalButton = 200;

- (UIButton *)decimalButton
{
    if (_decimalButton == nil) {
        _decimalButton = (UIButton *)[self viewWithTag:tagDecimalButton];
    }
    
    return _decimalButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureDecimalButton];
}

- (void)configureDecimalButton
{
    NSString *decimalSymbol = [[IAECurrencyManager sharedManager] decimalSeparator];
    [self.decimalButton setTitle:decimalSymbol forState:UIControlStateNormal];
}

@end
