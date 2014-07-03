//
//  Functions.h
//  FlashProtob
//
//  Created by Henry Flurry on 11/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Process Info

typedef struct
{
	BOOL		success;
	NSUInteger	mine;
	NSUInteger	used;
	NSUInteger	free;
	NSUInteger	total;
} MemoryInfo;

MemoryInfo memoryInfo(void);

unsigned long totalDiskSpaceInBytes(void);  
unsigned long freeDiskSpaceInBytes(void);

void reportMyMemory(NSString * header) ;
void reportFreeMemory (NSString * header) ;
