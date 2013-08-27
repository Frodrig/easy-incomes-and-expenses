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

static const CGFloat kWhiteColorComponentForExternalGratePanel = 0.8;
static const CGFloat kWhiteColorAlphaComponentForExternalGratePanel = 1.0;
    
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
    [self.decimalButton setTitle:decimalSymbol forState:UIControlStateNormal];
}
    
- (void)configureAddButton
{
    [self.addButton setTitle:NSLocalizedString(kLtextAddButtonTitle, @"") forState:UIControlStateNormal];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self drawLeftVerticalLineWithContextRef:contextRef];
    [self drawRightVerticalLine:contextRef];
}

- (void)drawLeftVerticalLineWithContextRef:(CGContextRef)contextRef
{
    CGPoint startPosition = CGPointMake(self.keyboardContainerView.frame.origin.x, self.keyboardContainerView.frame.origin.y);
    CGPoint endPosition = CGPointMake(startPosition.x, startPosition.y + self.keyboardContainerView.bounds.size.height);
    [self drawLineWithContextRef:contextRef fromStartPosition:startPosition toEndPosition:endPosition];
}

- (void)drawRightVerticalLine:(CGContextRef)contextRef
{
    CGFloat xPosition = self.keyboardContainerView.frame.origin.x + self.keyboardContainerView.bounds.size.width;
    CGPoint startPosition = CGPointMake(xPosition, self.keyboardContainerView.frame.origin.y);
    CGPoint endPosition = CGPointMake(xPosition, startPosition.y + self.keyboardContainerView.bounds.size.height);
    [self drawLineWithContextRef:contextRef fromStartPosition:startPosition toEndPosition:endPosition];
}

- (void)drawLineWithContextRef:(CGContextRef)contextRef fromStartPosition:(CGPoint)startPosition toEndPosition:(CGPoint)endPosition
{
    CGContextSaveGState(contextRef);
    
    CGContextSetAllowsAntialiasing(contextRef, false);
    CGContextSetLineWidth(contextRef, 1.0);
    UIColor *color = [UIColor colorWithWhite:kWhiteColorComponentForExternalGratePanel alpha:kWhiteColorAlphaComponentForExternalGratePanel];
    CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
    CGContextMoveToPoint(contextRef, startPosition.x, startPosition.y);
    CGContextAddLineToPoint(contextRef, endPosition.x, endPosition.y);
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

@end
