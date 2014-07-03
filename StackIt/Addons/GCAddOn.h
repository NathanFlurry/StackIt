//
//  GCAddOn.h
//  AudioDemo
//
//  Created by David Such on 13/04/13.
//  Copyright (c) 2013 Reefwing Software. All rights reserved.
//
//  Version:    1.0 - Original (13/04/13)
//              1.1 - Volume control & monitoring added, metering enabled (14/04/14)

#import <Foundation/Foundation.h>
#import "CodeaAddon.h"

id GCAddOnInstance;

//  This class conforms to the CodeaAddon & AVAudioPlayerDelegate Protocols

@interface GCAddOn : NSObject<CodeaAddon>

//  Forward declare our Lua Audio functions. These are static to confine their scope
//  to this file. By default c functions are global.

static int gcAddOn_GarbageCollect(struct lua_State *state);

@end
