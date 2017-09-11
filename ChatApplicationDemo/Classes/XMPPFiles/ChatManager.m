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
    BOOL _isConnectionOpen;
	BOOL _customerCartEvaluation;
	
	NSString* _userId;
	NSString* _password;
	
	
	XMPPStream* _xmppStream;
	XMPPReconnect* _xmppReconnect;
	
	XMPPRoster* _xmppRoster;
	XMPPvCardCoreDataStorage* _xmppVCardDataStorage;
	XMPPRosterCoreDataStorage*	_xmppRosterCoreDataStorage;
	XMPPvCardTempModule* _xmppVCardTempModule;
	XMPPvCardAvatarModule* _xmppvCardAvatarModule;
	
	XMPPCapabilities* _xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage* _xmppCapabilitiesCoreDataStorage;
	
	XMPPMessageArchivingCoreDataStorage* _xmppMessageArchivingCoreDataStorage;
	XMPPMessageArchiving* _xmppMessageArchiving;
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

	// for reconnecting in case of dissconection accidently
	_xmppReconnect = [[XMPPReconnect alloc] init];
	
	// roster basically defines your contact lists
	_xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
	_xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterCoreDataStorage];
	_xmppRoster.autoFetchRoster = YES;
	_xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	//vCard is to cache the Roster Images
	_xmppVCardDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
	_xmppVCardTempModule  = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppVCardDataStorage];
	_xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppVCardTempModule];
	
	// capability basically defines the list of things the client supports (Images, video etc) when it brodcasts itself
	_xmppCapabilitiesCoreDataStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
	_xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesCoreDataStorage];
	_xmppCapabilities.autoFetchHashedCapabilities = YES;
	_xmppCapabilities.autoFetchNonHashedCapabilities = NO;
	
	// manages message archiving
	_xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
	_xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
	
	// to set Archiving only for the sender(Client side)
	[_xmppMessageArchiving setClientSideMessageArchivingOnly:YES];
	
	// Activate all the modules
	_customerCartEvaluation = YES;
	[_xmppReconnect activate:_xmppStream];
	[_xmppRoster activate:_xmppStream];
	[_xmppVCardTempModule activate:_xmppStream];
	[_xmppvCardAvatarModule activate:_xmppStream];
	[_xmppCapabilities activate:_xmppStream];
	[_xmppMessageArchiving activate:_xmppStream];
	
	// adding delegates to module as this class
	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[_xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
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

#pragma mark- Core Data Methods

// as NSManaged Object context is not thread safe . It is not safe to use it outside main thread
-(NSManagedObjectContext* )managedObjectContext_roster
{
	return [_xmppRosterCoreDataStorage mainThreadManagedObjectContext];
}

-(NSManagedObjectContext* )managedObjectContext_capabilities
{
	return [_xmppCapabilitiesCoreDataStorage mainThreadManagedObjectContext];
}

#pragma mark- Roster Delegates
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	XMPPUserCoreDataStorageObject* userData = [_xmppRosterCoreDataStorage userForJID:[presence from] xmppStream:_xmppStream managedObjectContext:[self managedObjectContext_roster]];
	
	NSString* userName = [userData displayName];
	NSString* jidStrBare = [presence fromStr];
	NSString* body = nil;
	
	if(![userName isEqualToString:jidStrBare])
		body = [NSString stringWithFormat:@"Buddy requestFrom %@ <%@>", userName,jidStrBare];
	else
		body = [NSString stringWithFormat:@"Buddy requestFrom %@", userName];
	
	// pop notification of incoming user
	
	// if application is running
	if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		// pop user presence work to be done
	}
	else
	{
		UILocalNotification* localNotification = [[UILocalNotification alloc] init];
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
	XMPPUserCoreDataStorageObject *user = [_xmppRosterCoreDataStorage
										   userForJID:[presence from]
										   xmppStream:_xmppStream
										   managedObjectContext:[self managedObjectContext_roster]];
	
	DDLogVerbose(@"didReceivePresenceSubscriptionRequest from user %@ ",
				 user.jidStr); [_xmppRoster
								acceptPresenceSubscriptionRequestFrom:[presence from]
								andAddToRoster:YES];
}

#pragma mark- method to auto reconnect user
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
	DDLogVerbose(@"---------- xmppReconnect:shouldAttemptAutoReconnect: ----------");
	
	return YES;
}

#pragma mark Capabilities

- (void)xmppCapabilities:(XMPPCapabilities *)sender didDiscoverCapabilities:(NSXMLElement *)caps forJID:(XMPPJID *)jid
{
	DDLogVerbose(@"---------- xmppCapabilities:didDiscoverCapabilities:forJID: ----------");
	DDLogVerbose(@"jid: %@", jid);
	DDLogVerbose(@"capabilities:\n%@",
				 [caps XMLStringWithOptions:(NSXMLNodeCompactEmptyElement | NSXMLNodePrettyPrint)]);
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
    _isConnectionOpen = YES;
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
//    NSString* presenceType = [presence type];
//    NSString* userName = [[sender myJID]user];
//    NSString* presenceFromUser = [[presence from] user];
//    
//    if(![presenceFromUser isEqualToString:userName])
//    {
//       if([presenceType isEqualToString:@"available"])
//           [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
//		
//        else if ([presenceType isEqualToString:@"unavailable"])
//			[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
//    }
	
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
//    
//    NSString *msg = [[message elementForName:@"body"] stringValue];
//    NSString *from = [[message attributeForName:@"from"] stringValue];
//    
//    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
//    [m setObject:msg forKey:@"msg"];
//    [m setObject:from forKey:@"sender"];
//	[_messageDelegate newMessageRecieved:m];
}

#pragma mark- NSFetchedresults Controller Methods
-(NSFetchedResultsController* ) fetchFetchResultsControllerObj
{
	NSManagedObjectContext* managedObjectContext = [self managedObjectContext_roster];
	
	NSFetchedResultsController* fetchedResultsControllerObj;
	if(managedObjectContext)
	{
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:managedObjectContext];
	
	NSSortDescriptor* descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
	NSSortDescriptor* descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
	
	NSArray* sortDescriptorArray = @[descriptor1, descriptor2];
	
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:sortDescriptorArray];
	[fetchRequest setFetchBatchSize:10];
	
	fetchedResultsControllerObj = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionNum" cacheName:nil];
	
	NSError* error = nil;
	if(![fetchedResultsControllerObj performFetch:&error])
		DDLogError(@"error in fetching: %@", error);
	}
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
		if ([messageObject isKindOfClass:[XMPPMessageArchiving_Message_CoreDataObject class]])
		{
			
			XMPPMessageArchiving_Message_CoreDataObject *currentMessageCoreDataObject = (XMPPMessageArchiving_Message_CoreDataObject*)messageObject;
			XMPPMessage *message = currentMessageCoreDataObject.message;
			if (message!=nil) {
				[messages addObject:message];
			}
		}
	}];
	return messages;
}


@end
