//
//  IAEPopoverBackgroundCustom.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPopoverBackgroundCustom.h"
#import "IAEViewUtils.h"

#define CONTENT_INSET 10.0
#define CAP_INSET 17.0 
#define ARROW_BASE 32.0
#define ARROW_HEIGHT 19.0

@implementation IAEPopoverBackgroundCustom

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-popover.png"]];
        _borderImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"background-popover.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8.0,9.0,10.0,9.0)]];
        [self addSubview:_arrowView];
        [self insertSubview:_borderImageView belowSubview:_arrowView];
        self.alpha = 1;
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UIPopoverController class], nil]
         setTintColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGFloat) arrowOffset {
    return _arrowOffset;
}

- (void) setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
}

+(UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

+(CGFloat)arrowHeight {
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase {
    return ARROW_BASE;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat _height = self.frame.size.height;
    CGFloat _width = self.frame.size.width;
    CGFloat _left = 0.0;
    CGFloat _top = 0.0;
    CGFloat _coordinate = 0.0;
    CGAffineTransform _rotation = CGAffineTransformIdentity;
    CGAffineTransform borderImageRotation = CGAffineTransformIdentity;
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _top += ARROW_HEIGHT;
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, 1.4, ARROW_BASE, ARROW_HEIGHT);
        break;
        
        case UIPopoverArrowDirectionDown:
            _height -= ARROW_HEIGHT; _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
            _arrowView.frame = CGRectMake(_coordinate, _height - 3.4, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI );
        break;
        
        case UIPopoverArrowDirectionLeft:
            _left += ARROW_HEIGHT;
            _width -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(-4, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( -M_PI_2 );
        break;
        
        case UIPopoverArrowDirectionRight:
            _width -= ARROW_BASE - 12;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset)- (ARROW_HEIGHT/2);
            _arrowView.frame = CGRectMake(_width - 8, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation( M_PI_2 );
            borderImageRotation = CGAffineTransformMakeRotation( M_PI_2 );
        break;
            
        default:
            break;
    }
    
    [_borderImageView setTransform:borderImageRotation];
    _borderImageView.frame = CGRectMake(_left, _top, _width, _height);
    [_arrowView setTransform:_rotation];
}
@end
