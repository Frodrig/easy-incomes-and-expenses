//
//  IAEInAppPurchaseStoreViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInAppPurchaseStoreViewController.h"
#import "IAEInAppPurchasesStore.h"
#import "SKProduct+FormatedPrice.h"
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSUInteger, ControllerStateType) {
    ControllerStateTypeRequestingProVersionProduct,
    ControllerStateTypeErrorRequestinProVersionProduct,
    ControllerStateTypeShowingPurchaseAndRestore,
    ControllerStateTypePurchasingOrRestoring,
    ControllerStateTypeNone,
};

#pragma mark - Constants

static const NSUInteger kADLabelTag = 1;

#pragma mark - Interfaces

@interface IAEInAppPurchaseStoreViewController ()

@property (weak, nonatomic) IBOutlet UIView *purchaseRestoreContainerView;
@property (weak, nonatomic) IBOutlet UIView *messageWithRetryButtonContainerView;
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
@property (weak, nonatomic) IBOutlet UILabel *standAloneMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (nonatomic, strong) SKProduct *proVersionProduct;
@property (nonatomic) ControllerStateType state;

@end

#pragma mark - Implementation

@implementation IAEInAppPurchaseStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _state = ControllerStateTypeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.purchaseButton.enabled = NO;
    self.restoreButton.enabled = NO;
    
    [self configureNavigationItem];
    [self localizePurchaseRestoreContainerViewLabels];
}

- (void)configureNavigationItem
{
    self.navItem.title = NSLocalizedString(@"LTEXT_MAINNAVIGATION_TITLE_NOPROVERSION", @"");
}

- (void)localizePurchaseRestoreContainerViewLabels
{
    [self localizeRestorePurchaseLabels];
    [self localizeRestorePurchaseButtons];
}

- (void)localizeRestorePurchaseLabels
{
    [(UILabel *)[self.adInitialMonthView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADINITIALMONTH", @"")];
    [(UILabel *)[self.adPasswordView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADPASSWORD", @"")];
    [(UILabel *)[self.adFavoritesView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADFAVORITES", @"")];
    [(UILabel *)[self.adCSVView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADCSV", @"")];
    [(UILabel *)[self.adDuplicateMoveCopyView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADDUPLICATEMOVECOPY", @"")];
    [(UILabel *)[self.adAccesibilityView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADACCESIBILITY", @"")];
    [(UILabel *)[self.adFutureUpdatesView viewWithTag:kADLabelTag] setText:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ADFUTUREUPDATES", @"")];
}

- (void)localizeRestorePurchaseButtons
{
    [self.purchaseButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_PURCHASEBUTTON", @"") forState:UIControlStateNormal];
    [self.restoreButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_RESTOREBUTTON", @"") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setRequestingProVersionProduct];
}

- (void)requestProVersionProduct
{
    __weak IAEInAppPurchaseStoreViewController *weakSelf = self;
    [[IAEInAppPurchasesStore defaultStore] requestProVersionProductOnCompletion:^(SKProduct *product) {
        if (product) {
            weakSelf.proVersionProduct = product;
            [weakSelf.purchaseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_PURCHASEBUTTON", @""), [product formattedPrice]] forState:UIControlStateNormal];
            weakSelf.purchaseButton.enabled = YES;
            weakSelf.restoreButton.enabled = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - States

- (void)setRequestingProVersionProduct
{
    if (self.state != ControllerStateTypeRequestingProVersionProduct) {
        self.standAloneMessageLabel.text = NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_REQUESTINGPROVERSIONPRODUCT_MESSAGE", @"");
        self.retryButton.hidden = YES;
        self.messageWithRetryButtonContainerView.hidden = NO;
        self.purchaseRestoreContainerView.hidden = YES;
        self.navItem.rightBarButtonItem.enabled = NO;
        [self requestProVersionProduct];
        self.state = ControllerStateTypeRequestingProVersionProduct;
    }
}

#pragma mark - DoneButtonPressed

- (IBAction)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PurchaseButtonPressed

- (IBAction)purchaseButtonPressed:(id)sender
{
    [[IAEInAppPurchasesStore defaultStore] payForProduct:self.proVersionProduct];    
}

#pragma mark - RestoreButtonPressed

- (IBAction)restoreButtonPressed:(id)sender
{
}

@end
