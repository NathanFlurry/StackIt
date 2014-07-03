//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>

id AlertAddOnInstance;

@interface AlertAddOn : NSObject<CodeaAddon,UIAlertViewDelegate>
{
    struct lua_State *luaState;
    int callbackIndex;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int initAlert(struct lua_State *state);
static int addAlertButton(struct lua_State *state);
static int showAlert(struct lua_State *state);

@end
