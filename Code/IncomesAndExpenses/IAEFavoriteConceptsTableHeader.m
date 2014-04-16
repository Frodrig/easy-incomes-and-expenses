//
//  IAEFavoriteConceptsTableHeader.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 09/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEFavoriteConceptsTableHeader.h"
#import "IAEValueDecoratorView.h"

@interface IAEFavoriteConceptsTableHeader()

@property (nonatomic, weak) IBOutlet IAEValueDecoratorView *typeDecorator;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end

@implementation IAEFavoriteConceptsTableHeader

- (void)setSelectButtonState:(SelectButtonState)selectButtonState
{
    if (selectButtonState == SelectButtonStateHide) {
        _selectButton.hidden = YES;
    } else if (selectButtonState == SelectButtonStateSelectAll) {
        _selectButton.hidden = NO;
        [_selectButton setTitle:NSLocalizedString(@"LTEXT_FAVORITE_SELECT_ALL", @"") forState:UIControlStateNormal];
    } else if (selectButtonState == SelectButtonStateDeselectAll) {
        _selectButton.hidden = NO;
        [_selectButton setTitle:NSLocalizedString(@"LTEXT_FAVORITE_UNSELECT_ALL", @"") forState:UIControlStateNormal];
    }
    
    _selectButtonState = selectButtonState;
}

- (void)setDecoratorValueType:(EconomicValueType)decoratorValueType
{
    _titleLabel.text = decoratorValueType == ECONOMIC_INCOME_VALUE ? NSLocalizedString(@"LTEXT_CATEGORYTYPEINCOME_NAME", @"") : NSLocalizedString(@"LTEXT_CATEGORYTYPEEXPENSE_NAME", @"");
    _typeDecorator.economicValueType = decoratorValueType;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)vinculeForTouchEventTarget:(id)target withSelector:(SEL)selector
{
    [self.selectButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)desvinculeForTouchEventTarget:(id)target
{
    [self.selectButton removeTarget:target action:NULL forControlEvents:UIControlEventTouchUpInside];
}

@end
