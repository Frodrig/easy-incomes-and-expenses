//
//  IAEInfoAboutAndOptionsCollectionViewCellDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEInfoAboutAndOptionsCollectionViewCell;

@protocol IAEInfoAboutAndOptionsCollectionViewCellDelegate <NSObject>

- (void)feedbackEmailButtonWasPressedIninfoAboutOptionsCollectionViewCell:(IAEInfoAboutAndOptionsCollectionViewCell *)cell;

@end
