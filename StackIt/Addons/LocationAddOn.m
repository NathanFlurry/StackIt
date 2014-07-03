//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "LocationAddOn.h"

@implementation LocationAddOn

static bool didGetLocation = false;

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        LocationAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"LocationAddOn Registering Functions");
    
    lua_register(L, "setLocation", setLocation);
    lua_register(L, "getLatitude", getLatitude);
    lua_register(L, "getLongitude", getLongitude);

    self.codeaViewController = controller;
}

#pragma mark - Set Location

static int setLocation(struct lua_State *state) {
    lua_pushboolean(state, [LocationAddOnInstance setLocationAction]);
    
    return 1;
}


- (bool) setLocationAction {
    if ([CLLocationManager locationServicesEnabled])// && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
        didGetLocation = true;
    } else {
        didGetLocation = false;
    }
    if (didGetLocation) {
        return true;
    } else {
        return false;
    }
}

#pragma mark - Get Latitude

static int getLatitude(struct lua_State *state) {
    if (didGetLocation) {
        lua_pushnumber(state, (lua_Number)([LocationAddOnInstance getLatitudeAction]));
    } else {
        lua_pushnil(state);
    }
    
    return 1;
}


- (double) getLatitudeAction {
    return locationManager.location.coordinate.latitude;
}

#pragma mark - Get Longitude

static int getLongitude(struct lua_State *state) {
    if (didGetLocation) {
        lua_pushnumber(state, (lua_Number)([LocationAddOnInstance getLongitudeAction]));
    } else {
        lua_pushnil(state);
    }
    
    
    return 1;
}

- (double) getLongitudeAction {
    return locationManager.location.coordinate.longitude;
}

@end
