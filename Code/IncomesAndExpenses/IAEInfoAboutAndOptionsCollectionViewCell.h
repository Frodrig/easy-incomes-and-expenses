//
//  IAEInfoAboutAndOptionsCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 17/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEInfoAboutAndOptionsCollectionViewCellDelegate;

@interface IAEInfoAboutAndOptionsCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak)id<IAEInfoAboutAndOptionsCollectionViewCellDelegate> delegate;
@property(nonatomic) BOOL canSendMail;

+ (CGSize)sizeOfItem;

- (IBAction)feedbackButtonPressed:(id)sender;

@end
