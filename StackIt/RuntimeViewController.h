//
//  RuntimeViewController.h
//  StackIt
//
//  Created by Nathan Flurry on Wednesday, October 9, 2013
//  Copyright (c) Nathan Flurry. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface RuntimeViewController : GLKViewController

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) GLKView *glView;

@end
