//
//  IAEInAppPurchasesStore.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInAppPurchasesStore.h"
#import <StoreKit/StoreKit.h>
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEHasthUtilities.h"

#pragma mark - Constants

static NSString * const kInAppPurchaseProVersionIdentifier = @"com.easyincomesandexpenses.frodrig.proversion";

#pragma mark - Definition

@interface IAEInAppPurchasesStore()<SKProductsRequestDelegate,
                                    SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, strong) void(^productRequestCompletionBlock)(SKProduct *);

@end

#pragma mark - Implementation

@implementation IAEInAppPurchasesStore

#pragma mark - Class

+ (instancetype)defaultStore
{
    static IAEInAppPurchasesStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[IAEInAppPurchasesStore alloc] init];
    });
    
    return defaultStore;
}


#pragma mark - Begin/End transacctions

- (void)beginTransationObserverSession
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)endTransactionObserverSessio;
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *paymentTransacction in transactions) {
        switch (paymentTransacction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStatePurchased:
                // Pending - Validate transaction
                [self finishTransactionAndGiveFeaturesWithPaymentTransaction:paymentTransacction];
                break;
                
            case SKPaymentTransactionStateFailed:
                break;
                
            case SKPaymentTransactionStateRestored:
                [self finishTransactionAndGiveFeaturesWithPaymentTransaction:paymentTransacction];
                break;
            default:
                break;
        }
    }
}

- (void)finishTransactionAndGiveFeaturesWithPaymentTransaction:(SKPaymentTransaction *)paymentTransacction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransacction];
    
    // ToDo:
    // - Validate receipt
    //   - Verify signature
    //   - Verify device
    //   - Make sure the product purchase is what must be
    // If the purchase is correct then, enableProVersion
    
    
    [[NSUserDefaults standardUserDefaults] enableProVersion];
}

#pragma mark - Questions

- (BOOL)isInAppPurchasesAccesible
{
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Actions

- (void)requestProVersionProductOnCompletion:(void(^)(SKProduct *product))completionBlock
{
    if (!self.productRequest) {
        self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kInAppPurchaseProVersionIdentifier]];
        self.productRequest.delegate = self;
        self.productRequestCompletionBlock = completionBlock;
        [self.productRequest start];
    }
}

- (void)payForProduct:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = [IAEHasthUtilities hashedValueForStringIdentifier:[[NSUserDefaults standardUserDefaults] userUniqueIdentifier]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasedProducts;
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (self.productRequestCompletionBlock) {
        self.productRequestCompletionBlock([self findProductFromProVersionProductsResponse:response]);
    }
    
    self.productRequest = nil;
    self.productRequestCompletionBlock = nil;
}

- (SKProduct *)findProductFromProVersionProductsResponse:(SKProductsResponse *)response
{
    SKProduct *product = nil;
    if (response.products.count > 0) {
        product = response.products[0];
    }

    return product;
}

@end
