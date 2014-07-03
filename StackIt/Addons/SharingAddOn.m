//
//  LocationAddOn.m
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "lua.h"
#import "SharingAddOn.h"

@implementation SharingAddOn

/*
 * CODEA HIDDEN FUNCTIONS -- not documented
 */
struct image_type_t;
struct image_type_t *checkimage(lua_State *L, int i);

typedef enum PersistenceImageAlpha
{
    PersistenceImageAlphaPremultiply,
    PersistenceImageAlphaNoPremultiply,
} PersistenceImageAlpha;

UIImage* createUIImageFromImage(struct image_type_t* image, PersistenceImageAlpha alphaOption);

static CodeaViewController * globalCodeaViewController;

#pragma mark - Initialisation

- (id)init
{
    self = [super init];
    if (self)
    {
        SharingAddOnInstance = self;
    }
    return self;
}

#pragma mark - CodeaAddon Delegate

- (void) codea:(CodeaViewController*)controller didCreateLuaState:(struct lua_State*)L
{
    NSLog(@"SharingAddOn Registering Functions");
    
    lua_register(L, "savePhoto", savePhoto);
    lua_register(L, "sendTweet", sendTweet);
    lua_register(L, "sendFaceBook", sendFaceBook);

    self.codeaViewController = controller;
    globalCodeaViewController = controller;
}

#pragma mark - Get Photo

static UIImage *getPhotoFromState (struct lua_State *state, int pos) {
    struct image_type_t* imageType = checkimage(state, pos);
    UIImage* image = createUIImageFromImage(imageType, PersistenceImageAlphaNoPremultiply);
    return image;
}

#pragma mark - Save Photo

static int savePhoto(struct lua_State *state) {
    
    UIImageWriteToSavedPhotosAlbum(getPhotoFromState(state,1), nil, nil, nil);
    
    return 0;
}

#pragma mark - Tweet Photo

static int sendTweet(struct lua_State *state) {
    globalCodeaViewController.paused = YES;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
        if (!lua_isnone(state, 2)) {
            NSLog(@"Image");
            [tweetSheet addImage:getPhotoFromState(state,2)];
        } else {
            NSLog(@"No image");
        }
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
            [globalCodeaViewController dismissViewControllerAnimated:YES completion:^{
                globalCodeaViewController.paused = NO;
            }];
        }];
        [globalCodeaViewController presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Tweeting not available"
                                  message: @"You are either not signed into Twitter, or you have restricted StackIt from using Twitter."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alert show];
        globalCodeaViewController.paused = NO;
    }
    
    return 0;
}

#pragma mark - FaceBook Photo

static int sendFaceBook(struct lua_State *state) {
    globalCodeaViewController.paused = YES;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *faceBookSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [faceBookSheet setInitialText:[NSString stringWithCString:lua_tostring(state, 1) encoding:NSUTF8StringEncoding]];
        if (!lua_isnone(state, 2)) {
            [faceBookSheet addImage:getPhotoFromState(state,2)];
        }
        [faceBookSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
            [globalCodeaViewController dismissViewControllerAnimated:YES completion:^{
                globalCodeaViewController.paused = NO;
            }];
        }];
        [globalCodeaViewController presentViewController:faceBookSheet animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"FaceBook posting not available"
                              message: @"You are either not signed into FaceBook, or you have restricted StackIt from using FaceBook."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        globalCodeaViewController.paused = NO;
    }
    
    return 0;
}


@end
