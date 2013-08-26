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

@property (nonatomic, weak) UIButton *deleteButton;
@property (nonatomic, weak) UIButton *decimalButton;
@property (nonatomic, weak) UIButton *addButton;
@property (nonatomic, weak) UIView *keyboardContainerView;

@end

@implementation IAEKeyboardPanelCalculatorView

static const NSUInteger kTagDeleteButton = 100;
static const NSUInteger kTagDecimalButton = 200;
static const NSUInteger kTagAddButton = 400;
static const NSUInteger kTagKeyboardContainerView = 300;

static const CGFloat kRadiusOfKeyboardContainerView = 5;
static const CGFloat kRadiusForButtons = 15;
    
static NSString * const kLtextAddButtonTitle = @"LTEXT_CALCULATOR_BUTTON_ADD";

#pragma mark - Properties

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

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = (UIButton *)[self viewWithTag:kTagDeleteButton];
    }
    
    return _deleteButton;
}

- (UIView *)keyboardContainerView
{
    if (!_keyboardContainerView) {
        _keyboardContainerView = (UIView *)[self viewWithTag:kTagKeyboardContainerView];
    }
    
    return _keyboardContainerView;
}

#pragma mark - Init

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
    [self configureKeyboardButtons];
    [self configureDecimalButton];
    [self configureAddButton];
    [self configureDeleteButton];
}

- (void)configureKeyboardButtons
{
    for (UIView *viewIt in self.keyboardContainerView.subviews) {
        if ([viewIt isKindOfClass:[UIButton class]]) {
            [viewIt addRoundedCorners:UIRectCornerAllCorners withRadius:kRadiusForButtons];
        }
    }
}

- (void)configureDecimalButton
{
    NSString *decimalSymbol = [[IAECurrencyManager sharedManager] decimalSeparator];
    [self.decimalButton addRoundedCorners:UIRectCornerAllCorners withRadius:kRadiusForButtons];
    [self.decimalButton setTitle:decimalSymbol forState:UIControlStateNormal];
}
    
- (void)configureAddButton
{
    [self.addButton setTitle:NSLocalizedString(kLtextAddButtonTitle, @"") forState:UIControlStateNormal];
    [self.addButton addRoundedCorners:UIRectCornerAllCorners withRadius:kRadiusForButtons];
}

- (void)configureDeleteButton
{
    [self.deleteButton addRoundedCorners:UIRectCornerAllCorners withRadius:kRadiusForButtons];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    
}

@end
