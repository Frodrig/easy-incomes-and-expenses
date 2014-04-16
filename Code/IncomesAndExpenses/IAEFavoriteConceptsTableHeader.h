//
//  IAEFavoriteConceptsTableHeader.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 09/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEValueDefs.h"

typedef NS_ENUM(NSUInteger, SelectButtonState) {
    SelectButtonStateSelectAll,
    SelectButtonStateDeselectAll,
    SelectButtonStateHide
};

@interface IAEFavoriteConceptsTableHeader : UIView

@property (nonatomic) EconomicValueType decoratorValueType;
@property (nonatomic) SelectButtonState selectButtonState;


@end
