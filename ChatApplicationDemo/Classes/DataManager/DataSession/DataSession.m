//
//  DataSession.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "DataSession.h"
#import "Define.h"
#import "Person.h"
@implementation DataSession

+(instancetype) initWithDataSession
{
	static dispatch_once_t once;
	static DataSession* sInstance=nil;
	if(sInstance == nil)
	{
		dispatch_once(&once, ^
					  {
						  sInstance = [[DataSession alloc] init];
					  });
	}
	return sInstance;
}

-(void) saveLoginCredentials:(Person* )PersonData
{
	[[NSUserDefaults standardUserDefaults] setObject:PersonData.loginId forKey:kUserIdKey];
	[[NSUserDefaults standardUserDefaults] setObject:PersonData.password forKey:kUserpasswordKey];
	[[NSUserDefaults standardUserDefaults] setObject:PersonData.name forKey:kUserNameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
