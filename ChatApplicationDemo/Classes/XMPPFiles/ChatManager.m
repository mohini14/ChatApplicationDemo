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

#if DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelInfo;
#endif


@implementation ChatManager
{
    id<ChatDelegate> _chatDelegate;
    id<MessageDelegate> _messageDelegate;
    BOOL _isOpen;
	NSString* _userId;
	NSString* _password;
}

+ (ChatManager*) sharedInstance
{
	static ChatManager* _sharedInstance = nil;
	
	static dispatch_once_t oncePredicate;
 
	dispatch_once(&oncePredicate, ^{
		
		_sharedInstance = [[ChatManager alloc] init];
		
		// add methods which takes care of logging
		[DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
	});
	return _sharedInstance;
}

#pragma mark- Private methods
// method creates the channel to manage the exchange of messages.
-(void) setUpStream
{
	_xmppStream = [[XMPPStream alloc]init];
	
	[_xmppStream setHostName:@"192.168.11.117"];
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

#pragma mark- Public method definations
-(BOOL) connect
{
	// Establish connection with XMPP
	[self setUpStream];
	
	_userId = [[NSUserDefaults standardUserDefaults] stringForKey:kUserIdKey];
	_password = [[NSUserDefaults standardUserDefaults] stringForKey:kUserpasswordKey];
	
	if(![_xmppStream isDisconnected])
		return YES;
	
	if(_userId == nil || _password == nil)
		return NO;
	
	if(_userId.length < kConstIntZero || _password.length < kConstIntZero)
		return NO;
	
	//set JID
	[_xmppStream setMyJID:[XMPPJID jidWithString:_userId]];
	
	NSError* error = nil;
	if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		[Utility promptMessageOnScreen:error.localizedDescription sender:nil];
		return NO;
		
		DDLogError(@"Error connecting: %@", error);
	}
	
	return YES;
}

-(void) disconnect
{
	[self goOffline];
	[_xmppStream disconnect];
}

#pragma mark- XMPP Delegate methods
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kcheckLoggingInNotification
														object:[NSNumber numberWithBool:NO]];
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    _isOpen = YES;
    NSError* error = nil;
    
    if(_password)
        [_xmppStream authenticateWithPassword:_password error:&error ];
	else
		DDLogError(@"Authentication failed: %@", error);
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    [self goOnline];
	
	// on successfull authentication
	[[NSNotificationCenter defaultCenter] postNotificationName:kcheckLoggingInNotification
														object:[NSNumber numberWithBool:YES]];
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
