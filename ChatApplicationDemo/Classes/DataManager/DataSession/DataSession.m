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

-(void) saveLoginCredentials:(Person* )personData
{
	[[NSUserDefaults standardUserDefaults] setObject:personData.xmppId forKey:kUserIdKey];
	[[NSUserDefaults standardUserDefaults] setObject:personData.userId forKey:kUserIdKey];
	[[NSUserDefaults standardUserDefaults] setObject:personData.password forKey:kUserpasswordKey];
	[[NSUserDefaults standardUserDefaults] setObject:personData.name forKey:kUserNameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
