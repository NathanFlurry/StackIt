//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "IAPAddOn.h"

@implementation IAPAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        IAPAddOnInstance = self;
        
        productKeys = [[NSMutableArray alloc] init];
        productList = [[NSMutableArray alloc] init];
        storeReady = false;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        loadingIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
        loadingIndicatorView.backgroundColor = [UIColor colorWithWhite:(CGFloat)0.0 alpha:(CGFloat).3];
        loadingIndicatorView.hidden = true;
        
        loadingIndicator= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenRect.size.width/2-40,screenRect.size.height/2-40,80,80)];
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [loadingIndicator startAnimating];
        [loadingIndicatorView addSubview:loadingIndicator];
        
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"StoreInteractionAddOn Registering Functions");
    
    lua_register(L, "registerItem", registerItem); // ID, return cost string
    lua_register(L, "initStore", initStore);
    lua_register(L, "purchaseItem", purchaseItem); // num
    lua_register(L, "restorePurchases", restorePurchases);

    self.codeaViewController = controller;
}


#pragma mark - IAP Lua Interaction

static int registerItem (struct lua_State *state) {
    [IAPAddOnInstance registerItemAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
    
    return 0;
}


- (void) registerItemAction : (NSString*) itemID {
    [productKeys addObject:itemID];
}

static int initStore (struct lua_State *state) {
    [IAPAddOnInstance initStoreAction:state];
    
    return 1;
}


- (void) initStoreAction : (lua_State*) state {
    storeManager = [[iAPManager alloc] initWithProductIDs:productKeys delegate:self];
    luaState = state;
    
    [self.codeaViewController.view addSubview:loadingIndicatorView];
}

static int purchaseItem (struct lua_State *state) {
    [IAPAddOnInstance purchaseItemAction:(int)lua_tointeger(state, 1)];
    
    return 0;
}


- (void) purchaseItemAction : (int) itemNum {
    if ([storeManager canMakePurchases] && storeReady == true) {
        [storeManager purchaseProductForProduct:[productList objectAtIndex:(NSUInteger)itemNum]];
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Something went wrong here." message:@"Please make sure you have internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
}

static int restorePurchases (struct lua_State *state) {
    [IAPAddOnInstance restorePurchasesAction];
    
    return 0;
}


- (void) restorePurchasesAction {
    [storeManager restoreProducts];
}

#pragma mark - iAPManager Events

-(void)productsLoaded:(NSArray *)products {
    // Gets rid of warning
}

-(void)productLoaded:(iAPProduct *)product {
    NSLog(@"Product loaded: %@",product.title);
    [productList addObject:product];
    
    lua_getglobal(luaState, "getProductInfo");
    lua_pushstring(luaState, [product.productID UTF8String]);
    lua_pushstring(luaState, [product.price UTF8String]);
    lua_call(luaState, 2, 0);
}

-(void)storeIsDoneLoading {
    storeReady = true;
    lua_pushboolean(luaState, true);
    lua_setglobal(luaState, "storeReady");
}

-(void)errorForLoadDidOccur {
    /*UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"There was an error in loading your product." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];*/
}

-(void)productIsBeingPurchased:(iAPProduct *)product {
    lua_getglobal(luaState, "productBeingPurchased");
    lua_pushstring(luaState, [product.productID UTF8String]);
    lua_call(luaState, 1, 0);
    
    [self setLoadingHidden:false];
}

-(void)completedTransactionForProduct:(iAPProduct *)product {
    UIAlertView *successAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Thank you" message:[NSString stringWithFormat:@"You successfully purchased the product \"%@\".",product.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [successAlert show];
    [self purchaseSucceeded:product];
    
    [self setLoadingHidden:true];
}

-(void)errorOccuredForProduct:(iAPProduct *)product {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was an error in purchasing the product \"%@\".",product.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [self purchaseFailed];
    
    [self setLoadingHidden:true];
}

-(void)restoreProduct:(iAPProduct *)product {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Restored product" message:[NSString stringWithFormat:@"The product \"%@\" was restored.",product.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];

    
    lua_getglobal(luaState, "restoredProducts");
    lua_pushstring(luaState, [product.productID UTF8String]);
    lua_call(luaState, 1, 0);
    
    [self setLoadingHidden:true];
}

-(void)noProductsRestored {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"No products to restore" message:@"You may have the wrong account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    
    lua_getglobal(luaState, "noRestoredProducts");
    lua_call(luaState, 0, 0);
    
    [self setLoadingHidden:true];
}

-(void)purchaseFailed {
    lua_getglobal(luaState, "productPurchaseFailed");
    lua_call(luaState, 0, 0);
    
    [self setLoadingHidden:true];
}

-(void)purchaseSucceeded : (iAPProduct*) product {
    lua_getglobal(luaState, "productPurchaseSucceeded");
    lua_pushstring(luaState, [product.productID UTF8String]);
    lua_call(luaState, 1, 0);
    
    [self setLoadingHidden:true];
}

// Loading indicator

-(void)setLoadingHidden:(BOOL)hidden {
    loadingIndicatorView.hidden = hidden;
}

@end
