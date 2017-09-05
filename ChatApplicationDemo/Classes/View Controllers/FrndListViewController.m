//
//  FrndListViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "FrndListViewController.h"
#import "LoginViewController.h"
#import "Define.h"

@interface FrndListViewController ()
{
	IBOutlet UITableView* _frndListTableView;
	
	NSMutableArray<Person* >* _frndListArray;
}

@end

@implementation FrndListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
}

@end
