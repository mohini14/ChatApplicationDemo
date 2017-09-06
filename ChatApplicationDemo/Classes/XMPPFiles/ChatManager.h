//
//  ChatManager.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatManager : NSObject<XMPPStreamDelegate, ChatDelegate>

@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, assign) id  _messageDelegate;

-(BOOL) connect;
-(void) disconnect;
-(void) goOnline;
-(void) goOffline;
-(void) setUpStream;

+(instancetype) sharedInstance;

#define kChatManagerSingletonObj [ChatManager sharedInstance]

@end
