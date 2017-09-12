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
	 IBOutlet UITableView* _chatTableView;
	 IBOutlet UITextView* _messageTextview;
	
	id<MessageDelegate > _messageDelegate;
	ChatManager* _chatManager;
	
	NSMutableArray<Person* >* _messageListArray;
}

@end

@implementation ChatViewController


#pragma mark- View life cycle methods
- (void)viewDidLoad
{
	[super viewDidLoad];
	_messageListArray = [[NSMutableArray alloc]init];
//	_messageDelegate = self;
	_chatManager = kChatManagerSingletonObj;
//
	_chatTableView.delegate = self;
	_chatTableView.dataSource = self;
	self.delegate = self;
//
//	[_chatManager setUpStream];
	
	NSArray* list = [kChatManagerSingletonObj fetchMessage:[self.buddy.xmppId bare]];
	for (XMPPMessage* message in list)
		[self setMessage:message];
	

	_chatManager.recievedMessage = ^(Person* person)
	{
		[_messageListArray addObject:person];
		[_chatTableView reloadData];
	};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark- Actions on VC
-(void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
	NSString* messageContent = text;
	
	if(messageContent.length > kConstIntZero)
	{
		[JSMessageSoundEffect playMessageSentSound];

			NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
			[body setStringValue:messageContent];
			
			NSXMLElement *message = [NSXMLElement elementWithName:kMessageKey];
			[message addAttributeWithName:@"type" stringValue:@"chat"];
			[message addAttributeWithName:@"to" stringValue:self.buddy.name];
			[message addChild:body];
		
		Person* person = [[Person alloc] initWithMessage:messageContent withDate:[NSDate date] forMediaTyoe:JSBubbleMediaTypeText withImage:nil withMessageType:[ NSString stringWithFormat:@"%@%@",kEmptyFieldNotation, [NSNumber numberWithInt:JSBubbleMessageTypeOutgoing]]];
		person.xmppId = nil;
	
		_messageTextview.text = kEmptyFieldNotation;
		[_messageListArray addObject:person];
		[_chatTableView reloadData];
//		[self AddNewMessageToArray:messageContent];
	}
}
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
	
	
	Person* person = [[Person alloc] initWithMessage:message.body withDate:date forMediaTyoe:[NSString stringWithFormat:@"%@%@",kEmptyFieldNotation,[NSNumber numberWithInteger:JSBubbleMediaTypeText]] withImage:@"" withMessageType:[NSString stringWithFormat:@"%@%@", kEmptyFieldNotation,[NSNumber numberWithInt:messageType]]];
	person.xmppId = self.buddy.name;
	
	[_messageListArray addObject:person];
	
	[kChatManagerSingletonObj sendElement:message];

	[_chatTableView reloadData];
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

//-(IBAction)closeChatButtonPressed:(UIButton *)sender
//{
//	[self dismissViewControllerAnimated:YES completion:nil];
//}
//
//#pragma mark- Table view Data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _messageListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// case message is sent by other person
//	if([_messageListArray[indexPath.row].message.messageType isEqualToString:kMessageRecievedType])
		return [self createRecievedMessageCell:indexPath forTableView:tableView];
	
	//case : own message needs to be dispalyed
//	return [self createSelfMessageTableView:indexPath forTableView:tableView];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 200;
}
//
//#pragma mark- Private method
//
// display the message of other peerson
-(RecievedMessageCell* ) createRecievedMessageCell:(NSIndexPath* )indexPath forTableView:(UITableView* )tableView
{
	RecievedMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:kRecievedMessageTableCellIdentifier];
	
	if(!cell)
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:kRecievedMessageNIBName owner:nil options:nil]firstObject];
	}
	
	[cell setUpcellAttributes:_messageListArray[indexPath.row]];
	cell.userInteractionEnabled = NO;
	return cell;
}

//// display self message
//-(SelfMessageTableCell* ) createSelfMessageTableView:(NSIndexPath* )indexPath forTableView:(UITableView* )tableView
//{
//	SelfMessageTableCell* cell = [tableView dequeueReusableCellWithIdentifier:kSelfMessageTabelCellIdentifier];
//	
//	if(!cell)
//	{
//		cell = [[[NSBundle mainBundle] loadNibNamed:kSelfmessageNIBName owner:nil options:nil]firstObject];
//	}
//	
//	[cell setUpcellAttributes:_messageListArray[indexPath.row]];
//	cell.userInteractionEnabled = NO;
//	return cell;
//}
//
// method adds new message sent by self to MessageArrayList
-(void) AddNewMessageToArray :(NSString* )messageContent
{
	_messageTextview.text = kEmptyFieldNotation;
	Person* person  = [[Person alloc]init];
	Message* message = [[Message alloc] init];
	
	message.messageData = messageContent;
	message.messadgeDate = [NSDate date];
	message.messageType = kMessageSelfType;
	person.message = message;
	
	[_messageListArray addObject:person];
	[_chatTableView reloadData];
}

//#pragma mark- Message Delegate methods
//-(void)newMessageRecieved:(NSMutableDictionary *)messageContent
//{
//	NSString *m = [messageContent objectForKey:@"msg"];
//	
//	[messageContent setObject:[m substituteEmoticons] forKey:@"msg"];
//	[messageContent setObject:[NSString getCurrentTime] forKey:@"time"];
//	
//	Person* person = [[Person alloc]init];
//	
//	person.message.messageData = m ;
//	[_messageListArray addObject:person];
//	[_chatTableView reloadData];
//	
//	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:_messageListArray.count-1
//												   inSection:0];
//	
//	[_chatTableView scrollToRowAtIndexPath:topIndexPath
//					  atScrollPosition:UITableViewScrollPositionMiddle
//							  animated:YES];
//	
//}
//

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return _messageListArray[indexPath.row].message.messageData;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	 return _messageListArray[indexPath.row].message.messadgeDate;
}
@end
