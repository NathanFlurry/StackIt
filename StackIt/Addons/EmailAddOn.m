//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "EmailAddOn.h"

@implementation EmailAddOn

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        EmailAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"MailAddOn Registering Functions");
    
    lua_register(L, "sendEmail", sendEmail);

    self.codeaViewController = controller;
}

#pragma mark - Start Email

static int sendEmail(struct lua_State *state) {
    lua_pushboolean(state, [EmailAddOnInstance sendEmailAction : state]);
    
    return 1;
}


- (bool) sendEmailAction : (lua_State*)state {
    if ([MFMailComposeViewController canSendMail])
    {
        luaState = state; // Make accecable by callback
        
        // API: recipient, subject, message
        
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        
        MFMailComposeViewController *message = [[MFMailComposeViewController alloc] init];
        message.mailComposeDelegate = self;
        
        
        
        NSArray *toRecipients = [NSArray arrayWithObject:[NSString stringWithCString:lua_tostring(luaState, 1) encoding:NSUTF8StringEncoding]];
        [message setToRecipients:toRecipients];
        
        [message setSubject: [NSString stringWithCString:lua_tostring(luaState, 2) encoding:NSUTF8StringEncoding]];
        
        [message setMessageBody:[NSString stringWithCString:lua_tostring(luaState, 3) encoding:NSUTF8StringEncoding] isHTML:YES];
        
        [self.codeaViewController presentViewController:message animated:YES completion:^{
                self.codeaViewController.paused = YES;
            }];
        
        return true;
    }
    else
    {
        return false;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    lua_getglobal(luaState, "emailSent");
	switch (result)
	{
		case MFMailComposeResultCancelled:
			lua_pushstring(luaState, "Email sending canceled");
			break;
		case MFMailComposeResultSaved:
			lua_pushstring(luaState, "Email saved");
			break;
		case MFMailComposeResultSent:
			lua_pushstring(luaState, "Email sent");
			break;
		case MFMailComposeResultFailed:
			lua_pushstring(luaState, "Email sending failed");
			break;
		default:
			lua_pushstring(luaState, "Email not sent (unknown error)");
			break;
	}
    
    lua_call(luaState,1,0);
    
	[self.codeaViewController dismissViewControllerAnimated:YES completion:^{
            self.codeaViewController.paused = NO;
        }];
}


@end
