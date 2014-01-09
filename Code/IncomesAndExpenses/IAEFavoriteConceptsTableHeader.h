//
//  IAEFavoriteConceptsTableHeader.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 09/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEValueDefs.h"

@interface IAEFavoriteConceptsTableHeader : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic) EconomicValueType decoratorValueType;

@end
