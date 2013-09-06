//
//  IAEEditModeConceptCollectionViewHeader.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEEditModeConceptCollectionViewHeader : UICollectionReusableView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *info;

+ (CGSize)sizeOfItem;

@end
