//
//  IAEDragPanelView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDragPanelView.h"
#import "UIView+RoundedCorners.h"

@implementation IAEDragPanelView

static NSUInteger radiusTopCorners = 20;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [self configureContainerView];
}

- (void)configureContainerView
{
    [self addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:radiusTopCorners];
}

@end
