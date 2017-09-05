//
//  NSDictionary+ChatApplicationDemo.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "NSDictionary+ChatApplicationDemo.h"

@implementation NSDictionary (ChatApplicationDemo)

-(NSString* ) stringForKey :(NSString* )key
{
	NSObject* obj = [self valueForKey:key];
	
	if([obj isKindOfClass:[NSString class]])
		return (NSString* )obj;
	
	return nil;
}

-(NSDictionary* ) dictForKey: (NSString* )key
{
	NSObject* obj = [self valueForKey:key];
	
	if([obj isKindOfClass:[NSDictionary class]])
		return (NSDictionary* )obj;
	
	return nil;
}

@end
