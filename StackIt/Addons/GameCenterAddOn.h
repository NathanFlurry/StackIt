//
//  GameCenterAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/10/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

id gameCenterAddOnInstance;

@interface GameCenterAddOn : NSObject<CodeaAddon, GKGameCenterControllerDelegate>
{
    bool hasGameCenter;
    bool authenticated;
    NSError *authenticationError;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int authenticatePlayer(struct lua_State *state);
static int showGameCenter(struct lua_State *state);
static int reportScore(struct lua_State *state);
static int showGCBanner(struct lua_State *state);

@end
