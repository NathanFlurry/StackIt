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
#import <CoreMotion/CoreMotion.h>

id LocationAddOnInstance;

@interface LocationAddOn : NSObject<CodeaAddon>
{
    CLLocationManager *locationManager;
    //bool didGetLocation;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int setLocation(struct lua_State *state);
static int getLatitude(struct lua_State *state);
static int getLongitude(struct lua_State *state);

@end
