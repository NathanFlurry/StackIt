//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>

id SharingAddOnInstance;

@interface SharingAddOn : NSObject<CodeaAddon>
{
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int getPhoto(struct lua_State *state);
static int savePhoto(struct lua_State *state);

@end
