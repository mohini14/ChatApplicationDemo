//
//  ChatViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "ChatViewController.h"
#import "SelfMessageTableCell.h"
#import "RecievedMessageCell.h"
#import "NSString+ChatApplicationDemo.h"

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
	_messageDelegate = self;
	_chatManager = kChatManagerSingletonObj;
	
	_chatTableView.delegate = self;
	_chatTableView.dataSource = self;
	
	[_chatManager setUpStream];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- Actions on VC
- (IBAction)sendMessageButtonpressed:(UIButton *)sender
{
	NSString* messageContent = _messageTextview.text;
	
	if(messageContent.length > kConstIntZero)
	{
			NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
			[body setStringValue:messageContent];
			
			NSXMLElement *message = [NSXMLElement elementWithName:kMessageKey];
			[message addAttributeWithName:@"type" stringValue:@"chat"];
			[message addAttributeWithName:@"to" stringValue:self.buddy.name];
			[message addChild:body];
			
			[_chatManager.xmppStream sendElement:message];
		
		[self AddNewMessageToArray:messageContent];
	}
}

-(IBAction)closeChatButtonPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Table view Data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _messageListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// case message is sent by other person
	if([_messageListArray[indexPath.row].message.messageType isEqualToString:kMessageRecievedType])
		return [self createRecievedMessageCell:indexPath forTableView:tableView];
	
	//case : own message needs to be dispalyed
	return [self createSelfMessageTableView:indexPath forTableView:tableView];

}

#pragma mark- Private method

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

// display self message
-(SelfMessageTableCell* ) createSelfMessageTableView:(NSIndexPath* )indexPath forTableView:(UITableView* )tableView
{
	SelfMessageTableCell* cell = [tableView dequeueReusableCellWithIdentifier:kSelfMessageTabelCellIdentifier];
	
	if(!cell)
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:kSelfmessageNIBName owner:nil options:nil]firstObject];
	}
	
	[cell setUpcellAttributes:_messageListArray[indexPath.row]];
	cell.userInteractionEnabled = NO;
	return cell;
}

// method adds new message sent by self to MessageArrayList
-(void) AddNewMessageToArray :(NSString* )messageContent
{
	_messageTextview.text = kEmptyFieldNotation;
	Person* person  = [[Person alloc]init];
	Message* message = [[Message alloc] init];
	
	message.messageData = messageContent;
	message.messadgeDate = [Utility getCurrentDateAndTime];
	message.messageType = kMessageSelfType;
	person.message = message;
	
	[_messageListArray addObject:person];
	[_chatTableView reloadData];
}

#pragma mark- Message Delegate methods
-(void)newMessageRecieved:(NSMutableDictionary *)messageContent
{
	NSString *m = [messageContent objectForKey:@"msg"];
	
	[messageContent setObject:[m substituteEmoticons] forKey:@"msg"];
	[messageContent setObject:[NSString getCurrentTime] forKey:@"time"];
	
	Person* person = [[Person alloc]init];
	
	person.message.messageData = m ;
	[_messageListArray addObject:person];
	[_chatTableView reloadData];
	
	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:_messageListArray.count-1
												   inSection:0];
	
	[_chatTableView scrollToRowAtIndexPath:topIndexPath
					  atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
	
}

@end
