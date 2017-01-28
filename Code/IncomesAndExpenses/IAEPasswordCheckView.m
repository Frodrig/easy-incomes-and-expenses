//
//  IAEPasswordCheckView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordCheckView.h"

static const CGFloat kShowHideCheckAnimationTime = 0.25;

@interface IAEPasswordCheckView()

@property (nonatomic, strong) UILabel *check;

@end

@implementation IAEPasswordCheckView

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
    [super awakeFromNib];

    [self configureBorderWith];
    [self createAndVinculeLabelCheck];
    [self hideCheckWithAnimation:NO];
}

- (void)configureBorderWith
{
    self.layer.borderWidth = 1.0;
}

- (void)createAndVinculeLabelCheck
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    _check = [[UILabel alloc] initWithFrame:self.bounds];
    _check.attributedText = [[NSAttributedString alloc] initWithString:@"*" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:150],
                                                                                         NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                         NSParagraphStyleAttributeName: paragraphStyle}];
    
    [self addSubview:_check];
    [_check sizeToFit];
    _check.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) * 1.8);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)showCheckWithAnimation:(BOOL)animation
{
    [self changeCheckAlphaValueTo:1.0 withAnimation:animation];
}

- (void)hideCheckWithAnimation:(BOOL)animation
{
    [self changeCheckAlphaValueTo:0.0 withAnimation:animation];
}

- (void)changeCheckAlphaValueTo:(CGFloat)alphaValue withAnimation:(BOOL)animation
{
    [UIView animateWithDuration:animation ? kShowHideCheckAnimationTime : 0 animations:^{
        self.check.alpha = alphaValue;
    }];
}


@end
