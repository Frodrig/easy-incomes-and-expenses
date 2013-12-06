//
//  IAEHelpIndexViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEHelpIndexViewControllerDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface IAEHelpIndexViewController : UITableViewController<IAEHelpIndexViewControllerDelegate,
                                                              MFMailComposeViewControllerDelegate>

@end
