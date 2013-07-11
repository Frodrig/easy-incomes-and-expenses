//
//  IAEYearSelectorCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEValueDecoratorView;

@interface IAEYearSelectorCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *economicDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end
