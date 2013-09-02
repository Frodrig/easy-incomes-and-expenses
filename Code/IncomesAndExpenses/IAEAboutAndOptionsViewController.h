//
//  IAEAboutAndOptionsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEInfoAboutAndOptionsCollectionViewCellDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface IAEAboutAndOptionsViewController : UIViewController<UICollectionViewDataSource,
                                                               UICollectionViewDelegateFlowLayout,
                                                               IAEInfoAboutAndOptionsCollectionViewCellDelegate,
                                                               MFMailComposeViewControllerDelegate>

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)segmentedControlPressed:(UISegmentedControl *)segmentedControl;

@end
