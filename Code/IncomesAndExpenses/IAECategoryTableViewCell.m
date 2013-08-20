//
//  IAECategoryTableViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 05/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryTableViewCell.h"
#import "UIView+RoundedCorners.h"
#import "IAECircleDecoratorView.h"

@interface IAECategoryTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *backgroundContainerView;

@end

@implementation IAECategoryTableViewCell

static const CGFloat kDurationOfStrokeStateAnimation = 0.25;
static const CGFloat kAlphaInStrokeState = 0.25;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    //[self.backgroundContainerView addRoundedCorners:UIRectCornerAllCorners withRadius:8.0];
}

#pragma mark - StrokeState

- (void)goToStrokeStateWithAnimation:(BOOL)animation
{
    [self changeToStrokeState:YES withAnimation:animation];
}

- (void)exitOfStrokeStateWithAnimation:(BOOL)animation
{
    [self changeToStrokeState:NO withAnimation:animation];
}

- (void)changeToStrokeState:(BOOL)strokeState withAnimation:(BOOL)animation
{
    if (strokeState != self.isInStrokeState) {
        _isInStrokeState = strokeState;
        CGFloat alphaValue = strokeState ? kAlphaInStrokeState : 1.0;
        [UIView animateWithDuration:animation ? kDurationOfStrokeStateAnimation : 0 animations:^{
            self.categoryLabel.alpha = alphaValue;
            self.openDecoratorView.alpha = alphaValue;
        }];
    }
}


@end
