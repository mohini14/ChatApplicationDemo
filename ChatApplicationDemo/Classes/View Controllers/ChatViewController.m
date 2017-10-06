//
//  ChatViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "ChatViewController.h"
#import "RecievedMessageCell.h"
#import "NSString+ChatApplicationDemo.h"
#import "JSBubbleView.h"
#import "JSMessageSoundEffect.h"

@interface ChatViewController ()
{
//	 IBOutlet UITableView* _chatTableView;
//	 IBOutlet UITextView* _messageTextview;
//	
//	id<MessageDelegate > _messageDelegate;
	ChatManager* _chatManager;
//
	NSMutableArray<Person* >* _messageListArray;
}

@end

@implementation ChatViewController

-(void) viewDidLoad
{
	[super viewDidLoad];
	[self initialViewSettings];
}

#pragma mark- Initial View setup
-(void) initialViewSettings
{
	self.delegate = self;
	_chatManager = kChatManagerSingletonObj;
}

#pragma mark- Actions on VC

- (void) setMessage:(XMPPMessage*)message
{
	NSString* messageUser = [[message from] user];
	NSDate* date = nil;
	NSXMLElement* delay = [message elementForName:@"delay"];
	if (delay) {
		date = [self delayTimeToNSDate:[delay attributeForName:@"stamp"].stringValue];
	} else {
		date = [NSDate date];
	}
	
	int messageType = (messageUser == nil) ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
	
	Person* person = [[Person alloc] init];
	[person initWithMessage:message.body withDate:date forMediaTyoe:JSBubbleMediaTypeText withImage:nil withMessageType:[NSString stringWithFormat:@"%@%@",kEmptyFieldNotation,[NSNumber numberWithInt:messageType]]];
	
	
	[_messageListArray addObject:person];
	[self.tableView reloadData];
}

-(NSDate *) delayTimeToNSDate:(NSString *)time_str
{
	time_str = [time_str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	time_str = [time_str stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
	NSDateFormatter * dateFormatrer = [[NSDateFormatter alloc]init];
	[dateFormatrer setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatrer setTimeZone:[NSTimeZone systemTimeZone]];
	NSDate* date_0zone = [dateFormatrer dateFromString:time_str];
	NSDate* date_8zone = [NSDate dateWithTimeInterval:8*60*60 sinceDate:date_0zone];
	return date_8zone;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _messageListArray.count;
}

#pragma mark- Message view delegates
-(void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
	if([text length] == 0)
		return;
	
	[JSMessageSoundEffect playMessageSentSound];
	
	NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
	[body setStringValue:text];
	
	NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
	[message addAttributeWithName:@"type" stringValue:@"chat"];
	[message addAttributeWithName:@"to" stringValue:self.buddy.userId];
	[message addChild:body];
	
	Person *obj = [[Person alloc] initWithMessage:text withDate:[NSDate date] forMediaTyoe:JSBubbleMediaTypeText withImage:nil withMessageType:[NSString stringWithFormat:@"%ld",(long)JSBubbleMessageTypeOutgoing]];
	
	[_chatManager sendElement:message];
	[_messageListArray addObject:obj];
	
	[self finishSend:NO];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [NSString stringWithFormat: @"%@%@",kEmptyFieldNotation,[[NSNumber numberWithInt: _messageListArray[indexPath.row].message.messageType]]];
	
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	MessageData *message = self.messageArray[indexPath.row];
	return message.mediaType;
}

- (UIButton *)sendButton
{
	return [UIButton defaultSendButton];
}

@end
