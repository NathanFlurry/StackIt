//
//  iAPManager.m
//  PaperWars
//
//  Created by Caleb Jonassaint on 12/21/12.
//  Copyright (c) 2012 theCodeMonsters. All rights reserved.
//

#import "iAPManager.h"
#import <StoreKit/StoreKit.h>

@interface iAPManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, retain) NSMutableDictionary *products_hard;
@end

@implementation iAPManager

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completedTransaction:transaction];
                NSLog(@"Transaction purchased");
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                NSLog(@"Transaction f    ailed: %@",transaction.error);
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                NSLog(@"Transaction restored");
                break;
        }
    }
}

- (void) restoreTransaction:(SKPaymentTransaction *)transaction
{
    iAPProduct *product = [self.products objectForKey:transaction.originalTransaction.payment.productIdentifier];
    [self.delegate restoreProduct:product];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) completedTransaction:(SKPaymentTransaction *)transaction
{
    iAPProduct *product = [self.products objectForKey:transaction.payment.productIdentifier];
    [self.delegate completedTransactionForProduct:product];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    iAPProduct *product = [self.products objectForKey:transaction.payment.productIdentifier];
    [self.delegate errorOccuredForProduct:product];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) restoreProducts {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) purchaseProductForProduct:(iAPProduct *)product
{
    SKProduct *productSK = [self.products_hard objectForKey:product.productID];
    iAPProduct *easyProduct = [self.products objectForKey:product.productID];
    if (product == nil) {
        [self.delegate errorOccuredForProduct:easyProduct];
        NSLog(@"No product");
    } else {
        @try {
            [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:productSK]];
            [self.delegate productIsBeingPurchased:easyProduct];
        }
        @catch (NSException *exception) {
            [self.delegate errorOccuredForProduct:easyProduct];
            NSLog(@"Exception: %@",exception);
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    NSMutableArray *myEasyProducts = [NSMutableArray array];
    for (unsigned int i = 0; i < myProducts.count; i++)
    {
        SKProduct *product = [myProducts objectAtIndex:i];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        
        iAPProduct *product_easy = [iAPProduct productWithPrice:formattedString productID:product.productIdentifier title:product.localizedTitle description:product.localizedDescription];
        [self.products_hard setObject:product forKey:product.productIdentifier];
        [self.products setObject:product_easy forKey:product.productIdentifier];
        if ([self.delegate respondsToSelector:@selector(productLoaded:)])
        {
            [self.delegate productLoaded:product_easy];
        }
        [myEasyProducts addObject:product_easy];
    }
    
    if ([self.delegate respondsToSelector:@selector(productsLoaded:)] && myEasyProducts)
    {
        [self.delegate productsLoaded:myProducts];
    }
    else if (myEasyProducts == nil)
    {
        [self.delegate errorForLoadDidOccur];
    }
    
    if ([self.delegate respondsToSelector:@selector(storeIsDoneLoading)])
        [self.delegate storeIsDoneLoading];
}

- (id) initWithProductIDs:(NSArray *)ids delegate:(id<iAPManagerDelegate>)delegate_T
{
    if ([SKPaymentQueue canMakePayments]) {
        // Display a store to the user.
        self.products = [NSMutableDictionary dictionary];
        self.products_hard = [NSMutableDictionary dictionary];
        self.delegate = delegate_T;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:ids]];
        [request setDelegate:self];
        [request start];
    } else {
        // Warn the user that purchases are disabled.
        [self.delegate errorForLoadDidOccur];
    }
    return self;
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if([queue.transactions count]>0){
        NSLog(@"Received restored transactions: %lu", (unsigned long)queue.transactions.count);
    }
    else {
        NSLog(@"No Product to restore");
        [self.delegate noProductsRestored];
    }
}

//
// call this before making a purchase
//
-(BOOL)canMakePurchases{
    return [SKPaymentQueue canMakePayments];
}

@end
