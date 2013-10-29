//
//  IAESettingsAboutAndOptionsCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEHelpConfigureConceptsWithDaysCell : UICollectionViewCell

+ (CGSize)sizeOfItem;

- (void)setDaySwitchValueOn:(BOOL)on;
- (IBAction)daySwitchValueChanged:(id)sender;

@end
