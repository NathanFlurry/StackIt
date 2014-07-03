//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

id StoreInteractionAddOnInstance;

@interface StoreInteractionAddOn : NSObject<CodeaAddon,SKStoreProductViewControllerDelegate>
{
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int showApp(struct lua_State *state);
static int rateApp(struct lua_State *state);

@end
