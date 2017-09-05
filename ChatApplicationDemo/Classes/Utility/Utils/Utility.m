//
//  Utility.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "Utility.h"

@implementation Utility

+(NSString* )getCurrentDateAndTime
{
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm a"];
	
	return [dateFormatter stringFromDate:[NSDate date]];
}

@end
