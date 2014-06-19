//
//  IAEInAppPurchasesStore.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInAppPurchasesStore.h"
#import <StoreKit/StoreKit.h>
#import "IAEHasthUtilities.h"
#import "NSUserDefaults+EasyIncAndExp.h"

#pragma mark - Constants

static NSString * const kInAppPurchaseProVersionIdentifier = @"versionpro.easyincomesandexpenses.frodrig.com";

#pragma mark - Definition

@interface IAEInAppPurchasesStore()<SKProductsRequestDelegate,
                                    SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, strong) void(^productRequestCompletionBlock)(SKProduct *product);
@property (nonatomic, strong) void(^paymentCompletionBlock)(NSError *error);
@property (nonatomic, strong) void(^restoreCompletionBlock)(NSError *error);

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
        if (paymentTransacction.transactionState != SKPaymentTransactionStatePurchasing) {
            switch (paymentTransacction.transactionState) {
                case SKPaymentTransactionStatePurchased:
                    [self finishTransactionAndGiveFeaturesWithPaymentTransaction:paymentTransacction withBlock:self.paymentCompletionBlock andError:nil];
                    break;
                    
                case SKPaymentTransactionStateFailed:
                    [self finishTransactionFailedWithPaymentTransaction:paymentTransacction];
                    break;
                    
                case SKPaymentTransactionStateRestored:
                    [self finishTransactionAndGiveFeaturesWithPaymentTransaction:paymentTransacction withBlock:self.restoreCompletionBlock andError:nil];
                    break;
                    
                default:
                    break;
            }

            self.paymentCompletionBlock = self.restoreCompletionBlock = nil;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.restoreCompletionBlock) {
        self.restoreCompletionBlock(error);
    }
    
    self.paymentCompletionBlock = self.restoreCompletionBlock = nil;
}

- (void)finishTransactionAndGiveFeaturesWithPaymentTransaction:(SKPaymentTransaction *)paymentTransacction withBlock:(void(^)(NSError *error))completionBlock andError:(NSError *)error
{
    [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransacction];
    
    // To Make Better:
    // - Validate receipt
    //   - Verify signature
    //   - Verify device
    //   - Make sure the product purchase is what must be
    // If the purchase is correct then, enableProVersion
    
    if (completionBlock) {
        completionBlock(error);
    }
}

- (void)finishTransactionFailedWithPaymentTransaction:(SKPaymentTransaction *)paymentTransacction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransacction];
    if (self.paymentCompletionBlock) {
        self.paymentCompletionBlock(paymentTransacction.error);
    } else if (self.restoreCompletionBlock) {
        self.restoreCompletionBlock(paymentTransacction.error);
    }
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

- (void)payForProduct:(SKProduct *)product withCompletionBlock:(void(^)(NSError *error))completionBlock
{
    self.paymentCompletionBlock = completionBlock;
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = [IAEHasthUtilities hashedValueForStringIdentifier:[[NSUserDefaults standardUserDefaults] userUniqueIdentifier]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchasedProductsWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    self.restoreCompletionBlock = completionBlock;
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

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.productRequestCompletionBlock) {
        self.productRequestCompletionBlock(nil);
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
