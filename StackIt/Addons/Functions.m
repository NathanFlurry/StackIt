//
//  Functions.m
//  FlashProtob
//
//  Created by Henry Flurry on 11/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Functions.h"
#import <mach/task.h>
#import <mach/mach.h>


#pragma mark Process Info

void reportMyMemory(NSString * header) 
{
	NSString * lead = @"";

	if (header)
	{
		lead = header;
	}
	
	MemoryInfo mi = memoryInfo();

	if (mi.success)
	{
		NSLog(@"%@: Memory in use (in bytes): %lu", lead, (unsigned long)mi.mine);
	}
}

MemoryInfo memoryInfo(void)
{
	{
		BOOL	success = YES;

		// Get the system memory
		mach_port_t host_port;
		mach_msg_type_number_t host_size;
		vm_size_t pagesize;
		
		host_port = mach_host_self();
		host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
		host_page_size(host_port, &pagesize);        
	 
		vm_statistics_data_t vm_stat;
				  
		if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
		{
			NSLog(@"Failed to fetch vm statistics");
			success = NO;
		}
	 
		/* Stats in bytes */ 
		natural_t mem_used = (vm_stat.active_count +
							  vm_stat.inactive_count +
							  vm_stat.wire_count) * (natural_t)pagesize;
		natural_t mem_free = vm_stat.free_count * (natural_t)pagesize;
		natural_t mem_total = mem_used + mem_free;
		
		// Get my memory
		struct task_basic_info info;
		mach_msg_type_number_t size = sizeof(info);
		kern_return_t kerr = task_info(mach_task_self(),
									 TASK_BASIC_INFO,
									 (task_info_t)&info,
									 &size);

		vm_size_t resident_size = 0;
		
		if( kerr == KERN_SUCCESS ) {
			resident_size = info.resident_size;
		} else {
			NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
			success = NO;
		}
		
		MemoryInfo mi = { 0,0,0,0,0 };
		
		mi.success = success;
		mi.mine = resident_size;
		mi.used = mem_used;
		mi.free = mem_free;
		mi.total = mem_total;
		
		return mi;
	}
}
void reportFreeMemory (NSString * header) 
{
	NSString * lead = @"";

	if (header)
	{
		lead = header;
	}
	
	MemoryInfo mi = memoryInfo();

	if (mi.success)
	{
		NSLog(@"%@: VM used: %lu free: %lu total: %lu", lead, (unsigned long)mi.used, (unsigned long)mi.free, (unsigned long)mi.total);
	}

}

unsigned long totalDiskSpaceInBytes(void)
{  
    unsigned long totalSpace = (unsigned long)-1;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
  
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];  
        totalSpace = [fileSystemSizeInBytes unsignedIntValue];  
    } else {  
        NSLog(@"Error Obtaining File System Info");
    }  
  
    return totalSpace;  
}  

unsigned long freeDiskSpaceInBytes(void)
{  
    unsigned long totalSpace = (unsigned long)-1;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
  
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];  
        totalSpace = [fileSystemSizeInBytes unsignedIntValue];  
    } else {  
        NSLog(@"Error Obtaining File System Info");
    }  
  
    return totalSpace;  
}  

