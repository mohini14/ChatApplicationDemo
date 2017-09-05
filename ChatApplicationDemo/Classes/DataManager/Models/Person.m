//
//  Person.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "Person.h"
#import "Define.h"
#import "NSDictionary+ChatApplicationDemo.h"

@implementation Person

-(instancetype) initWithPerson : (NSDictionary* )personDetails
{
	self = [super init];
	if(self)
	{
		self.loginId  = [personDetails stringForKey:kUserpasswordKey];
		self.name     = [personDetails stringForKey:kUserNameKey];
		self.password = [personDetails stringForKey:kUserpasswordKey];
		self.message  = [[Message alloc]initWithMessage:[personDetails dictForKey:kMessageKey]];
	}
	return  self;
}
@end
