//
//  IAEEditModeConceptCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEValueDecoratorView;

@interface IAEEditModeConceptCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *valueDecoratorView;

@end
