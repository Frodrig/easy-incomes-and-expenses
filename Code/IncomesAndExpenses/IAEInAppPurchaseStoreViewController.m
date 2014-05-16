//
//  IAEInAppPurchaseStoreViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInAppPurchaseStoreViewController.h"

#pragma mark - Constants

static const NSUInteger kADLabelTag = 1;

#pragma mark - Interfaces

@interface IAEInAppPurchaseStoreViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIView *adInitialMonthView;
@property (weak, nonatomic) IBOutlet UIView *adPasswordView;
@property (weak, nonatomic) IBOutlet UIView *adFavoritesView;
@property (weak, nonatomic) IBOutlet UIView *adCSVView;
@property (weak, nonatomic) IBOutlet UIView *adDuplicateMoveCopyView;
@property (weak, nonatomic) IBOutlet UIView *adAccesibilityView;
@property (weak, nonatomic) IBOutlet UIView *adFutureUpdatesView;

@end

#pragma mark - Implementation

@implementation IAEInAppPurchaseStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationItem];
    [self localizeADLabels];
    [self localizeButtons];
}

- (void)configureNavigationItem
{
    self.navItem.title = NSLocalizedString(@"LTEXT_MAINNAVIGATION_TITLE_NOPROVERSION", @"");
}

- (void)localizeADLabels
{
    [(UILabel *)[self.adInitialMonthView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADINITIALMONTH", @"")];
    [(UILabel *)[self.adPasswordView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADPASSWORD", @"")];
    [(UILabel *)[self.adFavoritesView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADFAVORITES", @"")];
    [(UILabel *)[self.adCSVView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADCSV", @"")];
    [(UILabel *)[self.adDuplicateMoveCopyView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADDUPLICATEMOVECOPY", @"")];
    [(UILabel *)[self.adAccesibilityView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADACCESIBILITY", @"")];
    [(UILabel *)[self.adFutureUpdatesView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADFUTUREUPDATES", @"")];
}

- (void)localizeButtons
{
    [self.purchaseButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_PURCHASEBUTTON", @"") forState:UIControlStateNormal];
    [self.restoreButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_RESTOREBUTTON", @"") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DoneButtonPressed

- (IBAction)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
