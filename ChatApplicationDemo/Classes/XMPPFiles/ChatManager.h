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

-(BOOL) connect;
-(void) disconnect;
-(void) goOnline;
-(void) goOffline;
-(void) setUpStream;

+(instancetype) sharedInstance;
-(NSFetchedResultsController* ) fetchFetchResultsControllerObj;
- (NSArray*) fetchMessage:(NSString*)userId;

#define kChatManagerSingletonObj [ChatManager sharedInstance]

@end
