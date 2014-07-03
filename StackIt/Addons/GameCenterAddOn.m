//
//  GameCenterAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/10/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "GameCenterAddOn.h"

@implementation GameCenterAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        gameCenterAddOnInstance = self;
        authenticated = false;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"GameCenterAddOn Registering Functions");

    lua_register(L, "authenticatePlayer", authenticatePlayer);
    lua_register(L, "showGameCenter", showGameCenter);
    lua_register(L, "reportScore", reportScore);
    lua_register(L, "showGCBanner", showGCBanner);
    
    self.codeaViewController = controller;
}


#pragma mark - Authenticate player

static int authenticatePlayer(struct lua_State *state) {
    
    lua_pushboolean(state,[gameCenterAddOnInstance authenticatePlayerAction]);
    
    return 1;
}

- (bool) authenticatePlayerAction {
    NSLog(@"Attempting GameCenter authentication");
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    __weak GKLocalPlayer *blockLocalPlayer = localPlayer;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController != nil)
        {
            NSLog(@"Logging in to GameCenter");
            authenticated = true;
            [self.codeaViewController presentViewController: viewController animated: YES  completion:nil];
        }
        else if (blockLocalPlayer.isAuthenticated)
        {
            NSLog(@"GameCenter authenticated");
            authenticated = true;
        }
        else {
            NSLog(@"Authentication error: %@",error);
            authenticated = false;
            authenticationError = error;
        }
    };
    return authenticated;
}

#pragma mark - GameCenter start

static int showGameCenter(struct lua_State *state) {
    [gameCenterAddOnInstance showGameCenterAction];
    
    return 0;
}

- (void) showGameCenterAction {
    if (authenticated == true) {
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            self.codeaViewController.paused = YES;
            [self.codeaViewController presentViewController: gameCenterController animated: YES  completion:nil];
        }
    } else {
        [self authenticatePlayerAction];
        if (authenticationError.code == 2) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Please sign into GameCenter"
                                  message: @"To submit and view highscores on GameCenter, you must sign in."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *alertDetails = [NSString stringWithFormat:@"There was an error signing into GamceCenter.\nReadable error: %@\nError code: %ld",
                                      authenticationError.localizedDescription,
                                      (long)authenticationError.code];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"GameCenter Error"
                                  message: alertDetails
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController
                                           *)gameCenterViewController
{
    self.codeaViewController.paused = NO;
    [self.codeaViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save score

static int reportScore(struct lua_State *state) {
    [gameCenterAddOnInstance reportScoreAction:(int)(atof(lua_tostring(state,1)))  forLeaderboardID: [NSString stringWithCString:lua_tostring(state, 2) encoding:NSUTF8StringEncoding]];
    
    return 0;
}

- (void) reportScoreAction : (int64_t) score forLeaderboardID: (NSString*) identifier
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        // iOS 7
        
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
    
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"Error saving score with error %@", [error localizedDescription]);
            }
        }];
    } else {
        //iOS 6
        
        /*GKScore *scoreReporter = [[GKScore alloc] initWithCategory:identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"Error saving score with error %@", [error localizedDescription]);
            }
        }];*/
    }
}

#pragma mark - Show GameCenter Banner

static int showGCBanner(struct lua_State *state) {
    [gameCenterAddOnInstance showGCBannerAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] withMessage:[NSString stringWithCString:lua_tostring(state, 2) encoding:NSUTF8StringEncoding]];
    
    return 0;
}

- (void) showGCBannerAction : (NSString*) title withMessage: (NSString*) message
{
    [GKNotificationBanner showBannerWithTitle: title message: message
                            completionHandler:nil];
}


@end
