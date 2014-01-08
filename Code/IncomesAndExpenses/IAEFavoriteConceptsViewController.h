//
//  IAEFavoriteConceptsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEStrokeAnimatableViewDelegate.h"

typedef NS_ENUM(NSUInteger, FavoriteConceptsOptions) {
    FC_ADD = 1 << 0,
    FC_REMOVE = 1 << 1
};

@protocol IAEFavoriteConceptsViewControllerDelegate;

@interface IAEFavoriteConceptsViewController : UIViewController<IAEStrokeAnimatableViewDelegate>

@property (nonatomic, weak)id<IAEFavoriteConceptsViewControllerDelegate> delegate;

- (instancetype)initWithOptions:(NSUInteger)options;

@end
