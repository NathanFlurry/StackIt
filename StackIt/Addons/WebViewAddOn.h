//
//  LocationAddOn.h
//  StackIt
//
//  Created by Nathan Flurry on 10/11/13.
//  Copyright (c) 2013 MyCompany. All rights reserved.
//

#import "CodeaAddon.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

id WebViewAddOnInstance;

@interface WebViewAddOn : NSObject<CodeaAddon,UIWebViewDelegate,UIScrollViewDelegate>
{
    NSMutableDictionary* webViews;
}

@property (weak, nonatomic) CodeaViewController *codeaViewController;

@end
