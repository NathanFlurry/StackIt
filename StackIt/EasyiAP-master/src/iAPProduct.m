//
//  iAPProduct.m
//  PaperWars
//
//  Created by Caleb Jonassaint on 12/22/12.
//  Copyright (c) 2012 theCodeMonsters. All rights reserved.
//

#import "iAPProduct.h"

@implementation iAPProduct

- (id) initWithPrice:(NSString *)price productID:(NSString *)pID title:(NSString *)title description:(NSString *)desc
{
    self.price = price;
    self.productID = pID;
    self.title = title;
    self.description = desc;
    return self;
}
+ (id) productWithPrice:(NSString *)price productID:(NSString *)pID title:(NSString *)title description:(NSString *)desc
{
    iAPProduct *product = [[iAPProduct alloc] init];
    product.price = price;
    product.productID = pID;
    product.title = title;
    product.description = desc;
    return product;
}
@end
