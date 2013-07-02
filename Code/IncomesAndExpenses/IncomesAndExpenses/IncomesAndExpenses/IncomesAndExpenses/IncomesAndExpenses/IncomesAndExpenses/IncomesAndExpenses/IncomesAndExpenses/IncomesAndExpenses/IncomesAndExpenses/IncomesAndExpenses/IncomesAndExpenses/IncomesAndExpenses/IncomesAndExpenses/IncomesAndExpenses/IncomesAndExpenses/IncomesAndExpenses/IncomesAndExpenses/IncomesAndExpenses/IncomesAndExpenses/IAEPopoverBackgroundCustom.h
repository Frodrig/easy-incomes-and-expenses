//
//  IAEPopoverBackgroundCustom.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 28/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEPopoverBackgroundCustom : UIPopoverBackgroundView
{
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@end
