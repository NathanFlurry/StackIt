//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#include "lauxlib.h"
#import "WebViewAddOn.h"

@implementation WebViewAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        WebViewAddOnInstance = self;
        webViews = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"WebViewAddOn Registering Functions");
    
    lua_register(L, "addWebView", addWebView);
    lua_register(L, "addHTMLWebView", addHTMLWebView);
    lua_register(L, "setWebViewX", setWebViewX);
    lua_register(L, "setWebViewY", setWebViewY);
    lua_register(L, "setWebViewWidth", setWebViewWidth);
    lua_register(L, "setWebViewHeight", setWebViewHeight);
    lua_register(L, "runWebViewJavaScript", runWebViewJavaScript);
    lua_register(L, "setWebViewScrollingAllowed", setWebViewScrollingAllowed);
    lua_register(L, "removeWebView", removeWebView);
    
    self.codeaViewController = controller;
}

#pragma mark - Add Web View

static int addWebView(struct lua_State *state) {
    [WebViewAddOnInstance addWebViewAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]
                                      data:[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithCString:lua_tostring(state, 2) encoding:NSUTF8StringEncoding] ofType:@"html"]]
                                                                    encoding:NSUTF8StringEncoding error:nil]
                                        x:lua_tointeger(state, 3)
                                        y:lua_tointeger(state, 4)
                                        width:lua_tointeger(state, 5)
                                    height:lua_tointeger(state, 6)];
    
    return 0;
}

static int addHTMLWebView(struct lua_State *state) {
    int i = 1;
    const char * ident = lua_tostring(state, i++);
    const char * content = lua_tostring(state, i++);
    float x = lua_tointeger(state, i++);
    float y = lua_tointeger(state, i++);
    float width = lua_tointeger(state, i++);
    float height = lua_tointeger(state, i++);
    
    
    [WebViewAddOnInstance addWebViewAction:[NSString stringWithCString:ident encoding:NSUTF8StringEncoding]
                                      data:[NSString stringWithCString:content encoding:NSUTF8StringEncoding]
                                    x:x
                                    y:y
                                    width:width
                                    height:height];
    
    return 0;
}

- (void) addWebViewAction : (NSString*) ident data : (NSString*) data x : (float) x y : (float) y width : (float) width height : (float) height {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, width,height)];
    
    [webView loadHTMLString:data baseURL:[[NSBundle mainBundle] bundleURL]];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    
    webView.delegate = self;
    webView.scrollView.delegate = self;
    
    UIActivityIndicatorView* loadingIndicator= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(webView.frame.size.width/2-40,webView.frame.size.height/2-40,80,80)];
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [loadingIndicator startAnimating];
    [webView addSubview:loadingIndicator];
    
    [self.codeaViewController.view addSubview:webView];
    
    [webViews setObject:webView forKey:ident];
}

#pragma mark - Web view actions

static int setWebViewX(struct lua_State *state) {
    [WebViewAddOnInstance setWebViewXAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] x:lua_tointeger(state, 2)];
    
    return 0;
}


- (void) setWebViewXAction : (NSString*) ident x : (float) x {
    UIWebView* webView = [webViews objectForKey:ident];
    
    [webView setFrame:CGRectMake(x,webView.frame.origin.y,webView.frame.size.width,webView.frame.size.height)];
}

static int setWebViewY(struct lua_State *state) {
    [WebViewAddOnInstance setWebViewYAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] y:lua_tointeger(state, 2)];
    
    return 0;
}


- (void) setWebViewYAction : (NSString*) ident y : (float) y {
    UIWebView* webView = [webViews objectForKey:ident];
    
    [webView setFrame:CGRectMake(webView.frame.origin.x,y,webView.frame.size.width,webView.frame.size.height)];
}

static int setWebViewWidth(struct lua_State *state) {
    [WebViewAddOnInstance setWebViewWidthAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] width:lua_tointeger(state, 2)];
    
    return 0;
}


- (void) setWebViewWidthAction : (NSString*) ident width : (float) width {
    UIWebView* webView = [webViews objectForKey:ident];
    
    [webView setFrame:CGRectMake(webView.frame.origin.x,webView.frame.origin.y,width,webView.frame.size.height)];
}

static int setWebViewHeight(struct lua_State *state) {
    [WebViewAddOnInstance setWebViewHeightAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] height:lua_tointeger(state, 2)];
    
    return 0;
}


- (void) setWebViewHeightAction : (NSString*) ident height : (float) height {
    UIWebView* webView = [webViews objectForKey:ident];
    
    [webView setFrame:CGRectMake(webView.frame.origin.x,webView.frame.origin.y,webView.frame.size.width,height)];
}

static int runWebViewJavaScript(struct lua_State *state) {
    lua_pushstring(state,[[WebViewAddOnInstance runWebViewJavaScriptAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] script:[NSString stringWithCString:lua_tostring(state, 2) encoding:NSUTF8StringEncoding]] UTF8String]);
    return 1;
}


- (NSString*) runWebViewJavaScriptAction : (NSString*) ident script : (NSString*) script {
    UIWebView* webView = [webViews objectForKey:ident];
    
    NSString* result = [webView stringByEvaluatingJavaScriptFromString:script];
    
    return result;
}

static int setWebViewScrollingAllowed(struct lua_State *state) {
    [WebViewAddOnInstance setWebViewScrollingAllowedAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding] allowed:lua_toboolean(state, 2)];
    
    return 0;
}


- (void) setWebViewScrollingAllowedAction : (NSString*) ident allowed : (bool) allowed {
    UIWebView* webView = [webViews objectForKey:ident];
    
    webView.scrollView.scrollEnabled = allowed;
    webView.scrollView.bounces = allowed;
}

static int removeWebView(struct lua_State *state) {
    [WebViewAddOnInstance removeWebViewAction:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
    
    return 0;
}


- (void) removeWebViewAction : (NSString*) ident {
    UIWebView* webView = [webViews objectForKey:ident];
    
    [webView removeFromSuperview];
    
    [webViews removeObjectForKey:ident];
}

#pragma mark - Update on scrolling

static int setNeedsDisplay(struct lua_State *state) {
    [WebViewAddOnInstance setNeedsDisplayAction:lua_toboolean(state, 1)];
    return 1;
}


- (void) setNeedsDisplayAction : (bool) needsDisplay {
    self.codeaViewController.runtime.glView.enableSetNeedsDisplay = needsDisplay;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self.codeaViewController.runtime.glView display];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideWebViewLoadingIndicator:webView];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideWebViewLoadingIndicator:webView];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Loading Web View Failed"
                          message: @"We're sorry, we can not load this web view. Please try again or contact us."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(void)hideWebViewLoadingIndicator:(UIWebView*)webView {
    NSArray *subviews = webView.subviews;
    
    for(id view in subviews){
        if([view isKindOfClass:NSClassFromString(@"UIActivityIndicatorView")]){
            [view removeFromSuperview];
        }
    }
}

@end
