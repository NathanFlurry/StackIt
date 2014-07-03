//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "lauxlib.h"
#import "AlertAddOn.h"

@implementation AlertAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        AlertAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"AlertAddOn Registering Functions");
    
    lua_register(L, "advancedAlert", advancedAlert);

    self.codeaViewController = controller;
}

#pragma mark - Init Alert

static int advancedAlert (struct lua_State *state) {
    [AlertAddOnInstance advancedAlertAction:state];
    
    return 0;
}


- (void) advancedAlertAction : (lua_State*)state {
    // API: Title, message, cancel button, extra buttons, callback
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]
                                            message:[NSString stringWithCString:lua_tostring(state, 2) encoding:NSUTF8StringEncoding]
                                            delegate:self
                                            cancelButtonTitle:[NSString stringWithCString:lua_tostring(state, 3) encoding:NSUTF8StringEncoding]
                                            otherButtonTitles:nil];
    
    luaState = state; // Save state for callback
    
    // Add buttons from table
    lua_pushvalue(state, 4);
    
    lua_pushnil(state);
    while(lua_next(state, -2)) {
        if(lua_isstring(state, -1)) {
            NSString *str = [NSString stringWithCString:lua_tostring(state, -1) encoding:NSUTF8StringEncoding];
            [alert addButtonWithTitle:str];
        }
        lua_pop(state, 1);
    }
    lua_pop(state, 1);
    
    lua_pushvalue(state, 5);
    
    // Stores in the Lua Global Registry the value and returns an index
    // This is necessary because C should never hold Lua pointers, and it will also prevent
    // GC of it.
    callbackIndex = luaL_ref(state, LUA_REGISTRYINDEX);

    [alert show];
}

#pragma mark - Callbacks

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    // Get the value (a Lua function) from the registry and push on Lua stack
    lua_rawgeti(luaState, LUA_REGISTRYINDEX, callbackIndex);
    
    // push 2 args
    lua_pushnumber(luaState, (int)buttonIndex);
    lua_pushstring(luaState, [title UTF8String]);
    
    // Call the function we pushed on the stack, 2 args, no returns
    lua_call(luaState, 2, 0);
    
    // Releases and allows GC of the function.  This assumes that this function is only called once!
    luaL_unref(luaState, LUA_REGISTRYINDEX, callbackIndex);
    
    // to make sure we don't attempt to reference it again.
    callbackIndex = 0;
}


@end
