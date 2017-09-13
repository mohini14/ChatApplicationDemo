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
	BOOL _isRegistered;
	XMPPStream* _xmppStream;
	
	NSString* _userId;
	NSString* _password;
	
	
//	XMPPStream* _xmppStream;
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
	if(_xmppRosterCoreDataStorage)
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

- (void)sendElement:(NSXMLElement *)element
{
	[_xmppStream sendElement:element];
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
	NSLog(@"did not authenticate\n");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kcheckLoggingInNotification
														object:[NSNumber numberWithBool:NO]];
}


-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"Did connect method\n");
    _isConnectionOpen = YES;
    NSError* error = nil;
	
    if(_password)
		[_xmppStream authenticateWithPassword:_password error:&error];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"Did authenticate method\n");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    [self goOnline];
	
//	if(_isRegistered)
//	{
//		[self registerWithPassword:_password];
//	}
	// on successfull authentication
	[[NSNotificationCenter defaultCenter] postNotificationName:kcheckLoggingInNotification
														object:[NSNumber numberWithBool:YES]];
}

- (void) xmppStream:(XMPPStream*)sender socketDidConnect:(GCDAsyncSocket*)socket
{
	NSLog(@"socket did connect method\n");
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
    NSString* userName = [[sender myJID]user];
	
	self.userPresence = [presence type];
//    if(![presenceFromUser isEqualToString:userName])
//    {
//       if([presenceType isEqualToString:@"available"])
//           [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
//		
//        else if ([presenceType isEqualToString:@"unavailable"])
//			[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
//    }
	
	if(self.recievePresence)
		self.recievePresence(userName, _userPresence);
	
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];

	
	Person* person = [[Person alloc] init];
	person.message = [[Message alloc] init];
	
	person.name = from;
	
	person.message.messageData = msg;
	if(self.recievedMessage)
	{
		self.recievedMessage(person);
	}
	
	
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

#pragma mark- Resgistration Related method
-(void) registerWithElements : (NSArray* )elements andUserName:(NSString* )username andPassword:(NSString* )password
{

	XMPPJID* jid  = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",username, @"mindfire.com"]];
	[_xmppStream  setMyJID: jid];
//	NSLog(@"------Attempting registration for username %@ -------",_xmppStream.myJID.bare);

	_password = password;
//	_isRegistered = YES;
	NSError* error;

	if(![ _xmppStream isConnected])
	{
		[_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
	}
	else
		 [self registerWithPassword:_password];

	
	if(error)
	{
		NSLog(@"%@", error.localizedDescription);
	}
//	[self._xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}

-(BOOL) supportsInBandRegistration
{
	return _xmppStream.supportsInBandRegistration;
}

-(void) registerWithPassword: (NSString* )password
{
	 [_xmppStream registerWithPassword:password error:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
	DDXMLElement *errorXML = [error elementForName:@"error"];
	NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
	
	NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
	
	
	
	if([errorCode isEqualToString:@"409"])
		
		regError =  @"Username Already Exists!";
	
	if(self.recieveRegistrationMessage)
		self.recieveRegistrationMessage(regError);
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
	if(self.recieveRegistrationMessage)
		self.recieveRegistrationMessage(nil);
	
}

@end
