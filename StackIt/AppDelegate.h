//
//  AppDelegate.h
//  StackIt
//
//  Created by Nathan Flurry on Friday, March 7, 2014
//  Copyright (c) Nathan Flurry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPAddOn.h"
#import "WebViewAddOn.h"
#import "AlertAddOn.h"
#import "StoreInteractionAddOn.h"
#import "EmailAddOn.h"
#import "GCAddOn.h"
#import "GameCenterAddOn.h"
#import "SharingAddOn.h"

@class CodeaViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IAPAddOn  *iapAddOn;

@property (strong, nonatomic) WebViewAddOn  *webViewAddOn;

@property (strong, nonatomic) AlertAddOn  *alertAddOn;

@property (strong, nonatomic) StoreInteractionAddOn  *storeInteractionAddOn;

@property (strong, nonatomic) EmailAddOn  *emailAddOn;

@property (strong, nonatomic) GCAddOn  *gcAddOn;

@property (strong, nonatomic) GameCenterAddOn  *gameCenterAddOn;

@property (strong, nonatomic) SharingAddOn  *sharingAddOn;

@property (strong, nonatomic) CodeaViewController *viewController;

@end
