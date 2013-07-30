//
//  IAEReportAreaItemView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEReportAreaItemView.h"

@implementation IAEReportAreaItemView

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"");
    return nil;
}

- (id)init
{
    NSAssert(0, @"");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(0, @"");
    return nil;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title subtitle:(NSString *)subtitle andColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        
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

@end
