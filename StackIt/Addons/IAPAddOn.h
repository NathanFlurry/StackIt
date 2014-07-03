//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import "iAPManager.h"

id IAPAddOnInstance;

@interface IAPAddOn : NSObject<CodeaAddon,iAPManagerDelegate>
{
    struct lua_State *luaState;
    iAPManager* storeManager;
    NSMutableArray* productKeys;
    NSMutableArray* productList;
    bool storeReady;
    
    UIView* loadingIndicatorView;
    UIActivityIndicatorView* loadingIndicator;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

@end
