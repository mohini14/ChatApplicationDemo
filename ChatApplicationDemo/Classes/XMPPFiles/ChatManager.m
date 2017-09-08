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
	XMPPRosterCoreDataStorage*	_xmppRosterStorage;
}

+ (ChatManager*) sharedInstance
{
	static ChatManager* sharedInstance = nil;

	static dispatch_once_t oncePredicate;
 
	if(sharedInstance == nil)
	{
		dispatch_once(&oncePredicate, ^{
			
			sharedInstance = [[ChatManager alloc] init];
			
			// add methods which takes care of logging
			[DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
		});
	}
	return sharedInstance;
}

#pragma mark- Private methods
// method creates the channel to manage the exchange of messages.
-(void) setUpStream
{
	_xmppStream = [[XMPPStream alloc]init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		_xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif

	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[_xmppStream setHostName:@"192.168.11.117"];
	[_xmppStream setHostPort:5222];

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
	if(![_xmppStream connectWithTimeout:30 error:&error])
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

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
	NSLog(@"call....");
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

- (void) xmppStream:(XMPPStream*)sender socketDidConnect:(GCDAsyncSocket*)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSString *expectedCertName = [_xmppStream.myJID domain];
	if (expectedCertName)
	{
		settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
	}
	
//	if (_customCertEvaluation)
//	{
//		settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
//	}
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

#pragma mark- NSFetchedresults Controller Methods
-(NSFetchedResultsController* ) fetchFetchResultsControllerObj
{
	NSManagedObjectContext* managedObjectContext = [self managedObjectContext_roster];
	
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:managedObjectContext];
	
	NSSortDescriptor* descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
	NSSortDescriptor* descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
	
	NSArray* sortDescriptorArray = @[descriptor1, descriptor2];
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:sortDescriptorArray];
	[fetchRequest setFetchBatchSize:10];
	
	NSFetchedResultsController* fetchedResultsControllerObj = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionNum" cacheName:nil];
	
	NSError* error = nil;
	if(![fetchedResultsControllerObj performFetch:&error])
		DDLogError(@"error in fetching: %@", error);
	
	return fetchedResultsControllerObj;
	
}

- (NSArray*) fetchMessage:(NSString*)userId
{
	XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
	NSManagedObjectContext *managedObjContext = [storage mainThreadManagedObjectContext];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
											  inManagedObjectContext:managedObjContext];
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
	
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", userId];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *messagesArray = [managedObjContext executeFetchRequest:fetchRequest error:&error];
	NSMutableArray* messages = [[NSMutableArray alloc] initWithCapacity:messagesArray.count];
	[messagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id messageObject = [messagesArray objectAtIndex:idx];
		if ([messageObject isKindOfClass:[XMPPMessageArchiving_Message_CoreDataObject class]]) {
			
			XMPPMessageArchiving_Message_CoreDataObject *currentMessageCoreDataObject = (XMPPMessageArchiving_Message_CoreDataObject*)messageObject;
			XMPPMessage *message = currentMessageCoreDataObject.message;
			if (message!=nil) {
				[messages addObject:message];
			}
		}
	}];
	return messages;
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [_xmppRosterStorage mainThreadManagedObjectContext];
}

@end
