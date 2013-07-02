//
//  IAEViewCategoryTypeIndicator.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDefs.h"



@interface IAEViewCategoryTypeIndicator : UIView

@property (nonatomic) CategoryType category;

- (void)applyRoundedCorners;

@end
