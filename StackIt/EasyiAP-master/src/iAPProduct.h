//
//  iAPProduct.h
//  PaperWars
//
//  Created by Caleb Jonassaint on 12/22/12.
//  Copyright (c) 2012 theCodeMonsters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iAPProduct : NSObject
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
- (id) initWithPrice:(NSString *)price productID:(NSString *)pID title:(NSString *)title description:(NSString *)desc;
+ (id) productWithPrice:(NSString *)price productID:(NSString *)pID title:(NSString *)title description:(NSString *)desc;
@end
