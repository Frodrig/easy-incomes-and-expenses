//
//  UIView+LoadFromXib.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+LoadFromXib.h"

@implementation UIView (LoadFromXib)

+ (UIView *)viewFromXib:(NSString *)xibName
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FooterSection0ConceptsTableView" owner:self options:nil];
    return [nib objectAtIndex:0];
}

@end
