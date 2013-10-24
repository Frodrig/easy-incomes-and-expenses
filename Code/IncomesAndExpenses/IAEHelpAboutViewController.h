//
//  IAEHelpAboutViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEHelpAboutCollectionViewCellDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

@protocol IAEHelpIndexViewControllerDelegate;

@interface IAEHelpAboutViewController : UICollectionViewController<IAEHelpAboutCollectionViewCellDelegate,
                                                                   MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<IAEHelpIndexViewControllerDelegate> delegate;

@end
