//
//  AppDelegate.mm
//  StackIt
//
//  Created by Nathan Flurry on Friday, March 7, 2014
//  Copyright (c) Nathan Flurry. All rights reserved.
//

#import "AppDelegate.h"
#import "CodeaViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CodeaViewController alloc] init];
    
    self.iapAddOn = [[IAPAddOn alloc] init];
    [self.viewController registerAddon:self.iapAddOn];
    
    self.webViewAddOn = [[WebViewAddOn alloc] init];
    [self.viewController registerAddon:self.webViewAddOn];
    
    self.alertAddOn = [[AlertAddOn alloc] init];
    [self.viewController registerAddon:self.alertAddOn];
    
    self.storeInteractionAddOn = [[StoreInteractionAddOn alloc] init];
    [self.viewController registerAddon:self.storeInteractionAddOn];
    
    self.emailAddOn = [[EmailAddOn alloc] init];
    [self.viewController registerAddon:self.emailAddOn];
    
    self.gcAddOn = [[GCAddOn alloc] init];
    [self.viewController registerAddon:self.gcAddOn];
    
    self.gameCenterAddOn = [[GameCenterAddOn alloc] init];
    [self.viewController registerAddon:self.gameCenterAddOn];
    
    self.sharingAddOn = [[SharingAddOn alloc] init];
    [self.viewController registerAddon:self.sharingAddOn];
    
    NSString* projectPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"StackIt.codea"];
    
    [self.viewController loadProjectAtPath:projectPath];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSLog(@"Loaded add ons successfully.");
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

