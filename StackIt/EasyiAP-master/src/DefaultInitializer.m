//
//  DefaultInitializer.m
//  JangoEngine_lua
//
//  Created by Caleb Jonassaint on 1/27/13.
//  Copyright (c) 2013 theCodeMonsters. All rights reserved.
//

#import "DefaultInitializer.h"

@implementation DefaultInitializer

+ (id) shared
{
    static dispatch_once_t pred;
    static DefaultInitializer *theObject = nil;
    dispatch_once(&pred, ^{ theObject = [[self alloc] init]; });
    return theObject;
}

@end
