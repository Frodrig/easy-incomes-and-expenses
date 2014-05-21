//
//  IAELoaderIndicatorView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAELoaderIndicatorView.h"

static const CGFloat kAnimationDuration = 1.0;

@implementation IAELoaderIndicatorView

+ (instancetype)loaderIndicatorView
{
    IAELoaderIndicatorView *loaderIndicatorView = [[IAELoaderIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    loaderIndicatorView.animationImages = @[[UIImage imageNamed:@"imageLoader-1.gif"],
                                            [UIImage imageNamed:@"imageLoader-2.gif"],
                                            [UIImage imageNamed:@"imageLoader-3.gif"],
                                            [UIImage imageNamed:@"imageLoader-4.gif"],
                                            [UIImage imageNamed:@"imageLoader-5.gif"],
                                            [UIImage imageNamed:@"imageLoader-6.gif"],
                                            [UIImage imageNamed:@"imageLoader-7.gif"],
                                            [UIImage imageNamed:@"imageLoader-8.gif"],
                                            [UIImage imageNamed:@"imageLoader-9.gif"],
                                            [UIImage imageNamed:@"imageLoader-10.gif"],
                                            [UIImage imageNamed:@"imageLoader-11.gif"],
                                            [UIImage imageNamed:@"imageLoader-12.gif"],
                                            [UIImage imageNamed:@"imageLoader-13.gif"],
                                            [UIImage imageNamed:@"imageLoader-14.gif"],
                                            [UIImage imageNamed:@"imageLoader-15.gif"],
                                            [UIImage imageNamed:@"imageLoader-16.gif"],
                                            [UIImage imageNamed:@"imageLoader-17.gif"],
                                            [UIImage imageNamed:@"imageLoader-18.gif"],
                                            [UIImage imageNamed:@"imageLoader-19.gif"],
                                            [UIImage imageNamed:@"imageLoader-20.gif"],
                                            [UIImage imageNamed:@"imageLoader-21.gif"],
                                            [UIImage imageNamed:@"imageLoader-22.gif"],
                                            [UIImage imageNamed:@"imageLoader-23.gif"],
                                            [UIImage imageNamed:@"imageLoader-24.gif"]];
    loaderIndicatorView.animationDuration = kAnimationDuration;
    loaderIndicatorView.animationRepeatCount = 0;
    [loaderIndicatorView startAnimating];
    
    return loaderIndicatorView;
}


@end
