//
//  ChatManager.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>
@import XMPPFramework;

@interface ChatManager : NSObject<XMPPStreamDelegate, XMPPRosterDelegate>

@property (strong, nonatomic) void (^recievedMessage)(Person* );
@property (strong, nonatomic) void (^recievePresence)(NSString*, NSString*  );

-(BOOL) connect;
-(void) disconnect;
-(void) goOnline;
-(void) goOffline;
-(void) setUpStream;

@property (strong, nonatomic) NSString* userPresence;
@property (strong, nonatomic) XMPPStream* _xmppStream;

+(instancetype) sharedInstance;
-(NSFetchedResultsController* ) fetchFetchResultsControllerObj;
- (NSArray*) fetchMessage:(NSString*)userId;
- (void)sendElement:(NSXMLElement *)element;

#define kChatManagerSingletonObj [ChatManager sharedInstance]

@end
