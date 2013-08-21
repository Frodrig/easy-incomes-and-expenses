//
//  IAECategoryTableViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 05/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAECircleDecoratorView;

@interface IAECategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) UIView *containerForStrokeCategoryLabelView;
@property (weak, nonatomic) UILabel *categoryLabel;
@property (weak, nonatomic) IAECircleDecoratorView *openDecoratorView;
@property (weak, nonatomic) UILabel *numberOfConceptsLabel;
@property (nonatomic, readonly) BOOL isInStrokeState;

- (void)goToStrokeStateWithAnimation:(BOOL)animation;
- (void)exitOfStrokeStateWithAnimation:(BOOL)animation;

@end
