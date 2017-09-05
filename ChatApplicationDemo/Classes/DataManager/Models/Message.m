//
//  Messages.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "Message.h"
#import "Define.h"
#import "NSDictionary+ChatApplicationDemo.h"

@implementation Message

-(instancetype) initWithMessage: (NSDictionary* )messageData
{
	self = [super init];
	
	if(self)
	{
		self.messadgeDate = [messageData stringForKey:kMessagedateKey];
		self.messageData  = [messageData stringForKey:kMessagedataKey];
		self.messageType  = [messageData stringForKey:kMessageTypeKey];
	}
	return self;
}

@end
