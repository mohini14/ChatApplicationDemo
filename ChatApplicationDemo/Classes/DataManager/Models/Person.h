//
//  Person.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "XMPP.h"

@interface Person : NSObject

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) XMPPJID* xmppId;
@property (strong, nonatomic) NSString* userId;
@property (strong,nonatomic) NSString* password;
@property (strong, nonatomic) Message* message;
@property (strong,nonatomic) NSString* status;

-(instancetype) initWithPerson : (NSDictionary* )personDetails;
-(instancetype) initWithMessage: (NSString* )messageData withDate: (NSDate* )date forMediaTyoe:(NSString* )mediaType withImage:(NSString* )image withMessageType:(NSString* )messageType;

@end
