//
//  iAPManager.h
//  PaperWars
//
//  Created by Caleb Jonassaint on 12/21/12.
//  Copyright (c) 2012 theCodeMonsters. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAPProduct.h"
#import "DefaultInitializer.h"
@protocol iAPManagerDelegate <NSObject>
@required
- (void) errorForLoadDidOccur;
- (void) completedTransactionForProduct:(iAPProduct *)product;
- (void) productIsBeingPurchased:(iAPProduct *)product;
- (void) errorOccuredForProduct:(iAPProduct *)product;
@optional
- (void) storeIsDoneLoading;
- (void) restoreProduct:(iAPProduct *)product;
- (void) noProductsRestored;
- (void) productLoaded:(iAPProduct *)product;
- (void) productsLoaded:(NSArray *)products;
@end

@interface iAPManager : DefaultInitializer
@property (nonatomic, retain) NSMutableDictionary *products;
@property (nonatomic, retain) id<iAPManagerDelegate> delegate;
- (void) restoreProducts;
- (void) purchaseProductForProduct:(iAPProduct *)product;
- (BOOL)canMakePurchases;
- (id) initWithProductIDs:(NSArray *)ids delegate:(id<iAPManagerDelegate>)delegate_T;
@end
