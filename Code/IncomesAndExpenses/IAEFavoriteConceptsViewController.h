//
//  IAEFavoriteConceptsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FavoriteConceptsOptions) {
    FC_ADD = 1 << 0,
    FC_REMOVE = 1 << 1
};

@interface IAEFavoriteConceptsViewController : UIViewController

- (instancetype)initWithOptions:(NSUInteger)options;

@end
