//
//  FrndListViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "FrndListViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"

@interface FrndListViewController ()
{
	IBOutlet UITableView* _frndListTableView;
	
	NSMutableArray<Person* >* _frndListArray;
	ChatManager* _chatManger;
	id<ChatDelegate > _chatDelegate;
}

@end

@implementation FrndListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_chatManger = kChatManagerSingletonObj;
	
	[_chatManger setUpStream];
	_chatDelegate = self;
	[self initialVCSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self checkLoging];
}


#pragma mark- Initial VC setup
-(void) initialVCSetup
{
	_frndListArray = [[NSMutableArray alloc]init];
}

#pragma MARK- Table view Data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _frndListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FrndListTableCell* cell = [tableView dequeueReusableCellWithIdentifier:kFrndListTableCellIdentifier];

	
	if(cell == nil)
		cell = [[[NSBundle mainBundle]loadNibNamed:kFrndListNIBName owner:nil options:nil] firstObject];

	[cell setUPCell:_frndListArray[indexPath.row]];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:kFrndListToChatSegue sender:indexPath];
}

#pragma mark- Actions on VC
-(IBAction)showLogin:(id)sender
{
	LoginViewController* loginVC = [[LoginViewController alloc]init];
	[self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark- Private methods
-(void) checkLoging
{
	NSString* userId = [[NSUserDefaults standardUserDefaults] objectForKey: kUserIdKey];
	
	if(!userId)
		[self showLogin:nil];
	else if ([_chatManger connect])
	{
		NSLog(@"Show buddy list");
		[_chatDelegate newBuddyOnline:userId];
	}
}

#pragma mark- Chat Delegate Delegates
- (void)newBuddyOnline:(NSString *)buddyName
{
	Person* person = [[Person alloc]init];
	person.name = buddyName;
	[_frndListArray addObject:person];
	[_frndListTableView reloadData];
}

- (void)buddyWentOffline:(NSString *)buddyName
{
	Person* person = [[Person alloc]init];
	person.name = buddyName;

	[_frndListArray removeObject:person];
	[_frndListTableView reloadData];
}
#pragma mark- XMPP related methods

#pragma mark- Navigation Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath* indexPath = (NSIndexPath* )sender;
	
	if([segue.identifier isEqualToString:kFrndListToChatSegue])
	{
		ChatViewController* destVC = [segue destinationViewController];
		destVC.buddy = _frndListArray[indexPath.row];
	}
}
@end
