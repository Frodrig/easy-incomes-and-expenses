//
//  IAEDragPanelView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDragPanelCalculatorView.h"
#import "UIView+RoundedCorners.h"

@interface IAEDragPanelCalculatorView()

@property (nonatomic, weak) UILabel *title;

@end

@implementation IAEDragPanelCalculatorView

#pragma mark - Constants

static const NSUInteger kTagOfTitleLabel = 5;

static NSString * const kLtextTitleLabel = @"LTEXT_CALCULATOR_TITLE";
static const CGFloat kCalculatorTitleLabelKern = 5;

static const NSUInteger kRadiusTopCorners = 20;

#pragma mark - Properties

- (UILabel *)title
{
    if (!_title) {
        _title = (UILabel *)[self viewWithTag:kTagOfTitleLabel];
    }
    
    return _title;
}

#pragma mark - Init

- (void)awakeFromNib
{
    [self configureContainerView];
    [self configureTitleLabel];
}

- (void)configureContainerView
{
    [self addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:kRadiusTopCorners];
}

- (void)configureTitleLabel
{
    NSMutableDictionary *attributes = [[self.title.attributedText attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
    attributes[NSKernAttributeName] = @(kCalculatorTitleLabelKern);
    self.title.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLtextTitleLabel, @"") attributes:attributes];
}

@end
