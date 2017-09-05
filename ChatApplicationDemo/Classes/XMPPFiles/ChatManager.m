//
//  ChatManager.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "ChatManager.h"

@implementation ChatManager
{
	XMPPStream* _xmppStream;
}

+ (ChatManager*) sharedInstance
{
	static ChatManager* _sharedInstance = nil;
	
	static dispatch_once_t oncePredicate;
 
	dispatch_once(&oncePredicate, ^{
		_sharedInstance = [[ChatManager alloc] init];
	});
	return _sharedInstance;
}

// method creates the channel to manage the exchange of messages.
-(void) setUpStream
{
	_xmppStream = [[XMPPStream alloc]init];
	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//method let's a user to go online
-(void) goOnline
{
	XMPPPresence* userPresence = [XMPPPresence presence];
	[_xmppStream sendElement:userPresence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[_xmppStream sendElement:presence];
}

-(BOOL) connect
{
	// Establish connection with XMPP
	[self setUpStream];
	
	NSString* jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:kUserIdKey];
	NSString* passwoed = [[NSUserDefaults standardUserDefaults] stringForKey:kUserpasswordKey];
	
	if(![_xmppStream isDisconnected])
		return YES;
	
	if(jabberID == nil || passwoed == nil)
		return NO;
	
	if(jabberID.length < kConstIntZero || passwoed.length < kConstIntZero)
		return NO;
	
	//set JID
	[_xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
	
	NSError* error = nil;
	if(![_xmppStream connectWithTimeout:10 error:&error])
	{
		[Utility promptMessageOnScreen:error.localizedDescription sender:nil];
		return NO;
	}
	
	return YES;
}

-(void) disconnect
{
	[self goOffline];
	[_xmppStream disconnect];
}

@end
