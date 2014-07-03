//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "StoreInteractionAddOn.h"

@implementation StoreInteractionAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        StoreInteractionAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"StoreInteractionAddOn Registering Functions");
    
    lua_register(L, "showAppPreview", showApp);
    lua_register(L, "rateApp", rateApp);

    self.codeaViewController = controller;
}

#pragma mark - Show App

static int showApp (struct lua_State *state) {
    [StoreInteractionAddOnInstance showAppAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
    
    return 0;
}


- (void) showAppAction : (NSString*) appID {
    SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
    productViewController.delegate = self;
    NSDictionary *storeParameters = [NSDictionary dictionaryWithObject:appID forKey:SKStoreProductParameterITunesItemIdentifier];
    [productViewController loadProductWithParameters:storeParameters completionBlock:^(BOOL result, NSError *error) {
        if (!result) {
            NSLog(@"Failed to load product: %@", error);
        } else {
            [self.codeaViewController  presentViewController:productViewController animated:YES completion:^(void) {
                NSLog(@"Presented product with ID: %@", appID);
            }];
        }
    }];
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.codeaViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rate App

static int rateApp (struct lua_State *state) {
    [StoreInteractionAddOnInstance showAppAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
    
    return 0;
}


- (void) rateAppAction : (NSString*) appID {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID];
    } else {
        NSLog(@"Still in development");
    }
}

@end
