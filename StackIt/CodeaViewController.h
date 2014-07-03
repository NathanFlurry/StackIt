//
//  CodeaViewController.h
//  StackIt
//
//  Created by Nathan Flurry on Friday, March 7, 2014
//  Copyright (c) Nathan Flurry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RuntimeViewController.h"

@protocol CodeaAddon;

@class RuntimeViewController;

typedef enum CodeaViewMode
{
    CodeaViewModeStandard,
    CodeaViewModeFullscreen,
    CodeaViewModeFullscreenNoButtons,
} CodeaViewMode;

@interface CodeaViewController : UIViewController

@property (nonatomic, readonly) RuntimeViewController *runtime;
@property (nonatomic, assign) CodeaViewMode viewMode;
@property (nonatomic, assign) BOOL paused;

- (void) setViewMode:(CodeaViewMode)viewMode animated:(BOOL)animated;

- (void) loadProjectAtPath:(NSString*)path;

- (void) registerAddon:(id<CodeaAddon>)addon;

@end
