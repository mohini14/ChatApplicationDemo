//
//  ChatManager.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "ChatManager.h"
#import "ChatDelegate.h"
#import "MessageDelegate.h"

@implementation ChatManager
{
    id<ChatDelegate> _chatDelegate;
    id<MessageDelegate> _messageDelegate;
    BOOL _isOpen;
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

-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    _isOpen = YES;
    NSError* error = nil;
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:kUserpasswordKey])
        [_xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults] stringForKey:kUserpasswordKey] error:&error ];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self goOnline];
}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString* presenceType = [presence type];
    NSString* userName = [[sender myJID]user];
    NSString* presenceFromUser = [[presence from] user];
    
    if(![presenceFromUser isEqualToString:userName])
    {
       if([presenceType isEqualToString:@"available"])
           [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
		
        else if ([presenceType isEqualToString:@"unavailable"])
			[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
    }
	
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
	[_messageDelegate newMessageRecieved:m];
}
@end
