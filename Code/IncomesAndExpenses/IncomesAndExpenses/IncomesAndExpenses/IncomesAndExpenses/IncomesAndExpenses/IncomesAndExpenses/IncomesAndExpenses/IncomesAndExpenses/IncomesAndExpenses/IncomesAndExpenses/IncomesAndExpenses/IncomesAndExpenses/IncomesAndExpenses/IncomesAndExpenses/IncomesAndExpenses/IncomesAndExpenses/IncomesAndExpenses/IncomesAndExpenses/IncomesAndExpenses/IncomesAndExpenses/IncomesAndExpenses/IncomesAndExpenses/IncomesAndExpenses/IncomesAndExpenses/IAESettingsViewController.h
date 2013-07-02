//
//  IAESettingsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 27/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface IAESettingsViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) UIPopoverController *popoverFatherController;

@end
