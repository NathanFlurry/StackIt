//
//  CodeaAddon.h
//
//  This is an experimental protocol for adding native extensions to
//   exported Codea projects. You must deal with Lua directly to
//   register your functions and globals.
//
//  This protocol should be considered alpha and is subject to change
//   in future Codea releases.
//
//  Created by Simeon on 5/04/13.
//  Copyright (c) 2013 Two Lives Left. All rights reserved.
//

#import "CodeaViewController.h"

struct lua_State;

@protocol CodeaAddon <NSObject>

//For registering your custom functions and libraries
- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L;

@optional

//For clean up (if necessary)
- (void) codea:(CodeaViewController*)controller willCloseLuaState:(struct lua_State*)L;

//Handling changes to the viewer state (if necessary)
- (void) codea:(CodeaViewController*)controller didPause:(BOOL)pause;
- (void) codea:(CodeaViewController*)controller didChangeViewMode:(CodeaViewMode)mode;

//The reset button is pressed, this will cause:
//  willCloseLuaState and didCreateLuaState to be called again in sequence
- (void) codeaWillReset:(CodeaViewController*)controller;

//Called each frame update
- (void) codeaWillDrawFrame:(CodeaViewController*)controller withDelta:(CGFloat)deltaTime;

@end
