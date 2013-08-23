//
//  IAEKeyboardPanel.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEKeyboardPanelCalculatorView.h"
#import "IAECurrencyManager.h"
#import "UIView+RoundedCorners.h"

@interface IAEKeyboardPanelCalculatorView()

@property (nonatomic, weak) UIButton *decimalButton;
@property (nonatomic, weak) UIButton *addButton;
@property (nonatomic, weak) UIView *keyboardContainerView;

@end

@implementation IAEKeyboardPanelCalculatorView

static const NSUInteger kTagDecimalButton = 200;
static const NSUInteger kTagAddButton = 400;
static const NSUInteger kTagKeyboardContainerView = 300;

static const CGFloat kRadiusOfKeyboardContainerView = 15;
    
static NSString * const kLtextAddButtonTitle = @"LTEXT_CALCULATOR_BUTTON_ADD";

- (UIButton *)decimalButton
{
    if (!_decimalButton) {
        _decimalButton = (UIButton *)[self viewWithTag:kTagDecimalButton];
    }
    
    return _decimalButton;
}
    
- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = (UIButton *)[self viewWithTag:kTagAddButton];
    }
    
    return _addButton;
}

- (UIView *)keyboardContainerView
{
    if (!_keyboardContainerView) {
        _keyboardContainerView = (UIView *)[self viewWithTag:kTagKeyboardContainerView];
    }
    
    return _keyboardContainerView;
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
    [self configureVisualAspect];
    [self configureDecimalButton];
    [self configureAddButton];
}

- (void)configureVisualAspect
{
    //[self.keyboardContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:kRadiusOfKeyboardContainerView];
}

- (void)configureDecimalButton
{
    NSString *decimalSymbol = [[IAECurrencyManager sharedManager] decimalSeparator];
    [self.decimalButton setTitle:decimalSymbol forState:UIControlStateNormal];
}
    
- (void)configureAddButton
{
    [self.addButton setTitle:NSLocalizedString(kLtextAddButtonTitle, @"") forState:UIControlStateNormal];
}

@end
