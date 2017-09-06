//
//  Define.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Define : NSObject

// Cell Identifiers
#define  kFrndListTableCellIdentifier        @""
#define  kSelfMessageTabelCellIdentifier     @"SelfMessageTableCell"
#define  kRecievedMessageTableCellIdentifier @"RecievedMessageCell"


//XIB Names
#define kFrndListNIBName		@"FrndListcell"
#define kRecievedMessageNIBName @"RecievedMessageCell"
#define kSelfmessageNIBName		@"SelfMessageTableCell"

//Constant Colors
#define kAppMainColor [UIColor colorWithRed:0.871 green:0.345 blue:0.388 alpha:1.0]

//Keys
#define kUserNameKey     @"userName"
#define kUserpasswordKey @"password"
#define kUserIdKey       @"userId"
#define kMessagedataKey  @"messageData"
#define kMessagedateKey  @"messageDate"
#define kMessageTypeKey  @"messageType"
#define kMessageKey      @"message"

//const strings
#define kMessageRecievedType @"recievedMessage"
#define kMessageSelfType     @"selfMessage"
#define kEmptyFieldNotation  @""

// integer Constants
#define kConstIntZero	0

//Segue names
#define kLoginToFrndListSegue @"LoginToFrndListVC"
#define kFrndListToChatSegue  @"FrndListToChatVC"
@end
