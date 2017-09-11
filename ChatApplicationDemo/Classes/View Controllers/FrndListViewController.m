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
#import "HeaderView.h"
#import "XMPP.h"

@interface FrndListViewController ()
{
	IBOutlet UITableView* _frndListTableView;
	
	ChatManager* _chatManger;
	
	NSFetchedResultsController* _fetchedResultsControllerObj;
}

@end

@implementation FrndListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_chatManger = kChatManagerSingletonObj;
	
	[self initialVCSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[self checkLoging];
}

#pragma mark- Initial VC setup
-(void) initialVCSetup
{
	_fetchedResultsControllerObj = [_chatManger fetchFetchResultsControllerObj];
	_fetchedResultsControllerObj.delegate = self;
	
	//register header NIB
	[_frndListTableView registerNib:[UINib nibWithNibName:kHeaderViewNIBName bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:kHeaderViewIdentifierName];
}

#pragma MARK- Table view Data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _fetchedResultsControllerObj.sections.count;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray* fetchedResultsSection = [_fetchedResultsControllerObj sections];
	
	if(fetchedResultsSection.count > section)
	{
		id<NSFetchedResultsSectionInfo> rows = fetchedResultsSection[section];
		return rows.numberOfObjects;
	}
	
	return kConstIntZero;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray* fetchedResultsSection = [_fetchedResultsControllerObj sections];
	HeaderView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderViewIdentifierName];
	
	NSString* availabilityInfo = kEmptyFieldNotation;
	
	if(fetchedResultsSection.count > section)
	{
		id<NSFetchedResultsSectionInfo> rows = fetchedResultsSection[section];
		int sectionValue = [rows.name intValue];
		
		switch (sectionValue)
		{
			case 0:
				availabilityInfo = @"Available";
				break;
				
			case 1:
				availabilityInfo = @"Away";
				break;
				
			default:
				availabilityInfo = @"Offline";
		}
	}
	return  [headerView setHeaderTitleForTableSection:availabilityInfo];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FrndListTableCell* cell = [tableView dequeueReusableCellWithIdentifier:kFrndListTableCellIdentifier];

	
	if(cell == nil)
		cell = [[[NSBundle mainBundle]loadNibNamed:kFrndListNIBName owner:nil options:nil] firstObject];

	XMPPUserCoreDataStorageObject* user = [_fetchedResultsControllerObj objectAtIndexPath:indexPath];
	
	Person* person = [[Person alloc] init];
	
	person.name = user.displayName;
	
	[cell setUPCell:person];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:kFrndListToChatSegue sender:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 100;
}
#pragma mark- Actions on VC

#pragma mark- XMPP related methods

#pragma mark- NSFetchedResultsController Delegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[_frndListTableView reloadData];
}


//#pragma mark- Navigation Methods
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//	NSIndexPath* indexPath = (NSIndexPath* )sender;
//	
//	if([segue.identifier isEqualToString:kFrndListToChatSegue])
//	{
//		ChatViewController* destVC = [segue destinationViewController];
//		destVC.buddy = _frndListArray[indexPath.row];
//	}
//}
@end
