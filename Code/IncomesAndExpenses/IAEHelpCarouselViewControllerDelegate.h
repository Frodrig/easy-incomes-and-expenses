//
//  IAEHelpCarouselViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEHelpCarouselViewController;

@protocol IAEHelpCarouselViewControllerDelegate <NSObject>

- (void)helpCaruoselViewControllerDidDismiss:(IAEHelpCarouselViewController *)carouselViewController;

@end
