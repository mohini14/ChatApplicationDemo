//
//  LoginViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "LoginViewController.h"

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
	// case: fileds are not empty
	if(_usernameTextField.text.length > kConstIntZero && _passwordTextField.text.length > kConstIntZero && [_usernameTextField.text isEqualToString:@"mohini"] && [_passwordTextField.text isEqualToString:@"123"])
	{
		NSDictionary* personDetailsDict = @{ kUserIdKey :_usernameTextField.text,
											 kUserpasswordKey:_passwordTextField.text
											};
		
		// method will save user details in NSUserDefault
		[[DataSession initWithDataSession] saveLoginCredentials:[[Person alloc] initWithPerson:personDetailsDict]];
		
		[self performSegueWithIdentifier:kLoginToFrndListSegue sender:self];
	}
	else
		[Utility promptMessageOnScreen:NSLocalizedString(@"Please fill all the fields", nil) sender:self];
}

@end
