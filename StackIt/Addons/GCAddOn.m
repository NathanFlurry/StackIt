//
//  Nathan AddOns
//

#import "GCAddOn.h"
#import "lua.h"
#import "lauxlib.h"

@implementation GCAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
              GCAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

//  Classes which comply with the <CodeaAddon> Protocol must implement this method

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"GCAddOn Registering Functions");
    
    //  Register the TestFlight functions, defined below
    
    lua_register(L, "gcAddOn_GarbageCollect", gcAddOn_GarbageCollect);    // Takes no argument
    lua_register(L, "NSLog", luaNSLog);
    lua_register(L, "getAppVersion", luaGetAppVersion);
}

//  Optional method

- (void) codeaWillDrawFrame:(CodeaViewController*)controller withDelta:(CGFloat)deltaTime
{
    
}

#pragma mark - TestFlight Add On Functions and associated Methods

//  Objective C Methods


//  C Functions
//
//  Note that the returned value from all exported Lua functions is how many values that function should return in Lua.
//  For example, if you return 0 from that function, you are telling Lua that peakPowerForPlayer (for example) returns 0 values.
//  If you return 2, you are telling Lua to expect 2 values on the stack when the function returns.
//
//  To actually return values, you need to push them onto the Lua stack and then return the number of values you pushed on.


// This garbage collects for 1 ms  Call each frame to spread out the gc.

static int gcAddOn_GarbageCollect(struct lua_State *state)
{
    NSDate *date = [NSDate date];
    double endTime = [date timeIntervalSinceNow] + 0.001;
    double curTime;
    do {
        lua_gc(state, LUA_GCSTEP, 0);
        curTime = - [date timeIntervalSinceNow];
    } while(curTime  < endTime );
    return 0;
}

static int luaNSLog(struct lua_State *state) {
    [GCAddOnInstance luaNSLogAction:state];
    return 0;
}

-(void) luaNSLogAction:(lua_State*) state {
    NSLog(@"%@",[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]);
}


static int luaGetAppVersion(struct lua_State *state) {
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    lua_pushstring(state, [version UTF8String]);
    lua_pushstring(state, [build UTF8String]);
    lua_pushstring(state, [bundleName UTF8String]);
    
    return 3;
}


@end

