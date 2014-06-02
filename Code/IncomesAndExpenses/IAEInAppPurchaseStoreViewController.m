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
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEInAppPurchaseStoreViewControllerDefs.h"
#import "IAELoaderIndicatorView.h"
#import "Flurry.h"

typedef NS_ENUM(NSUInteger, ControllerStateType) {
    ControllerStateTypeRequestingProVersionProduct,
    ControllerStateTypeErrorRequestingProVersionProduct,
    ControllerStateTypeShowingPurchaseAndRestore,
    ControllerStateTypeWaitingForPurchaseOrRestore,
    ControllerStateTypeNone,
};

typedef NS_ENUM(NSUInteger, ThankYouAlertViewType) {
    ThankYouAlertViewTypeRestore,
    ThankYouAlertViewTypePurchase,
};

#pragma mark - Constants

static const CGFloat kFadeOutStateTime = 0.5;
static const CGFloat kFadeInStateTime = 0.75;

#pragma mark - Interfaces

@interface IAEInAppPurchaseStoreViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *purchaseRestoreContainerView;
@property (weak, nonatomic) IBOutlet UIView *messageWithRetryButtonContainerView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *featuresTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UILabel *standAloneMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIView *loaderIndicatorContainerView;
@property (nonatomic, strong) SKProduct *proVersionProduct;
@property (nonatomic) ControllerStateType state;
@property (nonatomic) BOOL leavingWithPurchaseOrRestore;
@property (nonatomic, strong) NSAttributedString *genericDescriptionAttributedText;

@end

#pragma mark - Implementation

@implementation IAEInAppPurchaseStoreViewController

#pragma mark - Properties

- (NSAttributedString *)genericDescriptionAttributedText
{
    if (!_genericDescriptionAttributedText) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentJustified;
        _genericDescriptionAttributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_GENERICDESCRIPTION", @"")
                                                                                  attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:22],
                                                                                               NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                               NSParagraphStyleAttributeName: paragraphStyle,
                                                                                               NSKernAttributeName: [NSNumber numberWithInteger:0]}];
    }
    
    return _genericDescriptionAttributedText;
}

#pragma mark - Init

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
    
    [self configureNavigationItem];
    [self localizePurchaseRestoreContainerViewLabels];
    [self localizeMessageWithRetryButtonContainerViewLabels];
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
    self.descriptionTextView.attributedText = self.genericDescriptionAttributedText;
}

- (void)localizeMessageWithRetryButtonContainerViewLabels
{
    [self.retryButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_RETRYBUTTON", @"") forState:UIControlStateNormal];
}

- (void)localizeRestorePurchaseButtons
{
    [self.purchaseButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_PURCHASEBUTTON", @"") forState:UIControlStateNormal];
    [self.restoreButton setTitle:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_RESTOREBUTTON", @"") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setRequestingProVersionProductState];
}

- (void)requestProVersionProduct
{
    __weak IAEInAppPurchaseStoreViewController *weakSelf = self;
    [[IAEInAppPurchasesStore defaultStore] requestProVersionProductOnCompletion:^(SKProduct *product) {
        if (product) {
            [weakSelf setShowingPurchaseAndRestoreStateWithProduct:product];
        } else {
            [weakSelf setErrorRequestingProVersionProductState];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - States

- (void)setRequestingProVersionProductState
{
    if (self.state != ControllerStateTypeRequestingProVersionProduct) {
        self.navItem.rightBarButtonItem.enabled = NO;
        [UIView animateWithDuration:kFadeOutStateTime animations:^{
            self.purchaseRestoreContainerView.alpha = 0;
            self.messageWithRetryButtonContainerView.alpha = 1;
        } completion:^(BOOL finished) {
            self.purchaseRestoreContainerView.alpha = 1;
            self.purchaseRestoreContainerView.hidden = YES;
            self.messageWithRetryButtonContainerView.alpha = 0;
            self.messageWithRetryButtonContainerView.hidden = NO;
            self.retryButton.hidden = YES;
            self.standAloneMessageLabel.text = NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_REQUESTINGPROVERSIONPRODUCT_MESSAGE", @"");
            [self requestProVersionProduct];
            [self addLoaderIndicatorView];
            self.state = ControllerStateTypeRequestingProVersionProduct;
            [UIView animateWithDuration:kFadeInStateTime animations:^{
                self.messageWithRetryButtonContainerView.alpha = 1.0;
            }];
        }];
    }
}

- (void)setErrorRequestingProVersionProductState
{
    if (self.state != ControllerStateTypeErrorRequestingProVersionProduct) {
        self.messageWithRetryButtonContainerView.alpha = 1;
        [UIView animateWithDuration:kFadeOutStateTime animations:^{
            self.purchaseRestoreContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.purchaseRestoreContainerView.alpha = 1;
            self.purchaseRestoreContainerView.hidden = YES;
            self.messageWithRetryButtonContainerView.alpha = 0;
            self.messageWithRetryButtonContainerView.hidden = NO;
            self.navItem.rightBarButtonItem.enabled = YES;
            self.standAloneMessageLabel.text = NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_ERRORREQUESTINGPROVERSIONPRODUCT_MESSAGE", @"");
            [self removeLoaderIndicatorView];
            self.state = ControllerStateTypeErrorRequestingProVersionProduct;
            [UIView animateWithDuration:kFadeInStateTime animations:^{
                self.messageWithRetryButtonContainerView.alpha = 1.0;
            }];
        }];
    }
}

- (void)setShowingPurchaseAndRestoreStateWithProduct:(SKProduct *)product
{
    if (self.state != ControllerStateTypeShowingPurchaseAndRestore) {
        self.purchaseRestoreContainerView.alpha = 1;
        [UIView animateWithDuration:kFadeOutStateTime animations:^{
            self.messageWithRetryButtonContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.messageWithRetryButtonContainerView.alpha = 1;
            self.messageWithRetryButtonContainerView.hidden = YES;
            self.purchaseRestoreContainerView.alpha = 0;
            self.purchaseRestoreContainerView.hidden = NO;
            self.proVersionProduct = product;
            [self.purchaseButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_PURCHASEBUTTON", @""), [self.proVersionProduct formattedPrice]] forState:UIControlStateNormal];
        
            self.featuresTextView.attributedText = [self featuresDescriptionAttributedTextForProduct:product];
            self.navItem.rightBarButtonItem.enabled = YES;
            [self removeLoaderIndicatorView];
            self.state = ControllerStateTypeShowingPurchaseAndRestore;
            [UIView animateWithDuration:kFadeInStateTime animations:^{
                self.purchaseRestoreContainerView.alpha = 1.0;
            }];
        }];
    }
}

- (NSAttributedString *)featuresDescriptionAttributedTextForProduct:(SKProduct *)product
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 8;

    return [[NSAttributedString alloc] initWithString:[self productDescriptionFromProduct:product]
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21],
                                                        NSForegroundColorAttributeName: [UIColor blackColor],
                                                        NSParagraphStyleAttributeName: paragraphStyle,
                                                        NSKernAttributeName: [NSNumber numberWithInteger:0.5]}];

}

- (NSString *)productDescriptionFromProduct:(SKProduct *)product
{
    NSString *productDescription = nil;
    if ([self isCatalanLanguageActive]) {
        productDescription = NSLocalizedString(@"LTEXT_PRODESCRIPTIONCATALAN", @"");
    } else {
        productDescription = product.localizedDescription;
    }
    
    return productDescription;
}

- (BOOL)isCatalanLanguageActive
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    const BOOL catalanLanguageActive = [language isEqualToString:@"ca"];
    
    return catalanLanguageActive;
}

- (void)setWaitingForPurchaseOrRestoreState
{
    if (self.state != ControllerStateTypeWaitingForPurchaseOrRestore) {
        self.messageWithRetryButtonContainerView.alpha = 1;
        [UIView animateWithDuration:kFadeOutStateTime animations:^{
            self.purchaseRestoreContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            self.purchaseRestoreContainerView.alpha = 1;
            self.purchaseRestoreContainerView.hidden = YES;
            self.messageWithRetryButtonContainerView.alpha = 0;
            self.messageWithRetryButtonContainerView.hidden = NO;
            self.standAloneMessageLabel.text = NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_WAITTINGFORPURCHASEORRESTORE_MESSAGE", @"");
            self.navItem.rightBarButtonItem.enabled = NO;
            [self addLoaderIndicatorView];
            self.state = ControllerStateTypeWaitingForPurchaseOrRestore;
            [UIView animateWithDuration:kFadeInStateTime animations:^{
                self.messageWithRetryButtonContainerView.alpha = 1.0;
            }];
        }];
    }
}

- (void)setCommonUIConfigurationForWaitingForPurchaseAndRestoreState
{
    self.purchaseRestoreContainerView.hidden = YES;
    self.messageWithRetryButtonContainerView.hidden = NO;
    self.retryButton.hidden = YES;
    self.standAloneMessageLabel.text = NSLocalizedString(@"LTEXT_PURCHASEPROVERSIONMODAL_WAITTINGFORPURCHASEORRESTORE_MESSAGE", @"");
    self.navItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - LoaderIndicatorView

- (void)addLoaderIndicatorView
{
    if (self.loaderIndicatorContainerView.subviews.count == 0) {
        [self.loaderIndicatorContainerView addSubview:[IAELoaderIndicatorView loaderIndicatorView]];
    }
}

- (void)removeLoaderIndicatorView
{
    if (self.loaderIndicatorContainerView.subviews.count > 0) {
        UIView *loaderIndicatorView = self.loaderIndicatorContainerView.subviews[0];
        [loaderIndicatorView removeFromSuperview];
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
    [Flurry logEvent:@"InAppPurchaseStore_PurchaseButtonPressed"];

    [self setWaitingForPurchaseOrRestoreState];
    [[IAEInAppPurchasesStore defaultStore] payForProduct:self.proVersionProduct withCompletionBlock:^(NSError *error) {
        [self checkPayProductsResultWithError:error];
    }];
}

#pragma mark - RestoreButtonPressed

- (IBAction)restoreButtonPressed:(id)sender
{
    [Flurry logEvent:@"InAppPurchaseStore_RestoreButtonPressed"];

    [self setWaitingForPurchaseOrRestoreState];
    [[IAEInAppPurchasesStore defaultStore] restorePurchasedProductsWithCompletionBlock:^(NSError *error) {
        [self checkRestoreProductsResultWithError:error];
    }];
}

- (void)checkPayProductsResultWithError:(NSError *)error
{
    [self checkPayOrRestureProductsResultWithError:error andThankyouAlertViewType:ThankYouAlertViewTypePurchase];
}

- (void)checkRestoreProductsResultWithError:(NSError *)error
{
    [self checkPayOrRestureProductsResultWithError:error andThankyouAlertViewType:ThankYouAlertViewTypeRestore];
}

- (void)checkPayOrRestureProductsResultWithError:(NSError *)error andThankyouAlertViewType:(ThankYouAlertViewType)alertViewType
{
    if (error) {
        if (error.code != SKErrorPaymentCancelled) {
            [self launchAlertViewWithPaymentOrRestoreProcessWithError:error];
        }
        [self setShowingPurchaseAndRestoreStateWithProduct:self.proVersionProduct];
    } else {
        [Flurry logEvent:@"InAppPurchaseStore_PROVERSIONENABLED"];
        [[NSUserDefaults standardUserDefaults] enableProVersion];
        self.leavingWithPurchaseOrRestore = YES;
        [self launchAlertViewThankYouOfType:alertViewType];
    }
}
         
- (void)launchAlertViewThankYouOfType:(ThankYouAlertViewType)alertViewType
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[self titleStringForAlertViewThankYouOfType:alertViewType]
                                                        message:[self messageStringForAlertViewThankYouOfType:alertViewType]
                                                       delegate:self
                                              cancelButtonTitle:[self cancelStringAlertViewThankYouOfType:alertViewType]
                                              otherButtonTitles:nil];
    [alertView show];
}

- (NSString *)titleStringForAlertViewThankYouOfType:(ThankYouAlertViewType)alertViewType
{
    NSString *retTitle = nil;
    switch (alertViewType) {
        case ThankYouAlertViewTypePurchase:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESPAYMENTDONETHANKYOU_ALERTVIEW_TITLE", @"");
            break;
        case ThankYouAlertViewTypeRestore:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESRESTORETHANKYOU_ALERTVIEW_TITLE", @"");
            break;
    }
    
    return retTitle;
}

- (NSString *)messageStringForAlertViewThankYouOfType:(ThankYouAlertViewType)alertViewType
{
    NSString *retTitle = nil;
    switch (alertViewType) {
        case ThankYouAlertViewTypePurchase:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESPAYMENTDONETHANKYOU_ALERTVIEW_MESSAGE", @"");
            break;
        case ThankYouAlertViewTypeRestore:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESRESTORETHANKYOU_ALERTVIEW_MESSAGE", @"");
            break;
    }
    
    return retTitle;
}

- (NSString *)cancelStringAlertViewThankYouOfType:(ThankYouAlertViewType)alertViewType
{
    NSString *retTitle = nil;
    switch (alertViewType) {
        case ThankYouAlertViewTypePurchase:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESPAYMENTDONETHANKYOU_ALERTVIEW_CANCEL", @"");
            break;
        case ThankYouAlertViewTypeRestore:
            retTitle = NSLocalizedString(@"LTEXT_INAPPPURCHASESRESTORETHANKYOU_ALERTVIEW_CANCEL", @"");
            break;
    }
    
    return retTitle;
}

- (void)launchAlertViewWithPaymentOrRestoreProcessWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_INAPPPURCHASESPROBLEMSINPAYMENTORRESTORE_ALERTVIEW_TITLE", @"") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"LTEXT_INAPPPURCHASESPROBLEMSINPAYMENTORRESTORE_ALERTVIEW_CANCEL", @"") otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - RetryButtonPressed

- (IBAction)retryButtonPressed:(id)sender
{
    [self setRequestingProVersionProductState];
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.leavingWithPurchaseOrRestore) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kProVersionEnabledFromStore object:self];
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
