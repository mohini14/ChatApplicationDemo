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
//		self.loginId  = [personDetails stringForKey:kUserIdKey];
		
		self.xmppId = [personDetails valueForKey:@"jid"];
		self.name     = [personDetails stringForKey:kUserNameKey];
		self.password = [personDetails stringForKey:kUserpasswordKey];
		self.userId = [personDetails stringForKey:kUserIdKey];
		self.message = [[Message alloc] init];
	}
	return  self;
}

-(instancetype) initWithMessage: (NSString* )messageData withDate: (NSDate* )date forMediaTyoe:(NSString* )mediaType withImage:(NSString* )image withMessageType:(NSString* )messageType
{
	self = [super init];
	
	self.message = [[Message alloc] init];
	if(self)
	{
		self.message.messadgeDate = date;
		self.message.messageData  = messageData;
		self.message.messageType  = messageType;
	}
	return self;
}


@end
