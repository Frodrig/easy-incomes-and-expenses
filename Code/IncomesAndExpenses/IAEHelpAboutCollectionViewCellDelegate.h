//
//  IAEInfoAboutAndOptionsCollectionViewCellDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEHelpAboutCollectionViewCell;

@protocol IAEHelpAboutCollectionViewCellDelegate <NSObject>

- (void)feedbackEmailButtonWasPressedInHelpAboutCollectionViewCell:(IAEHelpAboutCollectionViewCell *)cell;
- (void)urlButtonWasPressedInHelpAboutCollectionViewCell:(IAEHelpAboutCollectionViewCell *)cell;

@end
