//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

id EmailAddOnInstance;

@interface EmailAddOn : NSObject<CodeaAddon,MFMailComposeViewControllerDelegate>
{
    struct lua_State *luaState;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

static int sendEmail(struct lua_State *state);

@end
