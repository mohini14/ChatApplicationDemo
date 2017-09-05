//
//  LoginViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "LoginViewController.h"
#import "Define.h"
#import "DataSession.h"
#import "Person.h"

@interface LoginViewController ()
{
	 IBOutlet UITextField* _usernameTextField;
	 IBOutlet UITextField* _passwordTextField;
}
@end

@implementation LoginViewController

#pragma mark- Initial View Settings
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- Actions on VC
-(IBAction) loginButtonPressed:(id)sender
{
	if(_usernameTextField.text.length > kConstIntZero && _passwordTextField.text.length > kConstIntZero)
	{
		NSDictionary* personDetailsDict = @{ kUserIdKey :_usernameTextField.text,
											 kUserpasswordKey:_passwordTextField.text
											};
		
		// method will save user details in NSUserDefault
		[[DataSession initWithDataSession] saveLoginCredentials:[[Person alloc] initWithPerson:personDetailsDict]];
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
