//
//  IAEHelpPasswordIndexViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol IAEHelpIndexViewControllerDelegate;

@interface IAEHelpPasswordIndexViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic, weak)id<IAEHelpIndexViewControllerDelegate> delegate;

@end
