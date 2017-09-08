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

#pragma mark- View life cycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initialVCSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:kcheckLoggingInNotification];
}

-(void) viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:kcheckLoggingInNotification];
}

#pragma mark- Private methods
-(void) initialVCSetup
{
	// Hide navigation bar on Login screen
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	// add a Notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLoggingIn:) name:kcheckLoggingInNotification object:nil];
	
	//auto loggin
	[self autoLogging];
}

-(void) autoLogging
{
	NSUserDefaults* nsUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString* userId = [nsUserDefaults stringForKey:kUserIdKey];
	NSString* password = [nsUserDefaults stringForKey:kUserpasswordKey];
	
	if(userId.length > kConstIntZero && password.length > kConstIntZero)
	{
		_usernameTextField.text = userId;
		_passwordTextField.text = password;
		[self loginButtonPressed:nil];
	}
}

#pragma mark- Actions on VC
-(IBAction) loginButtonPressed:(id)sender
{
	// if fileds are empty
	if(!(_usernameTextField.text.length > kConstIntZero && _passwordTextField.text.length > kConstIntZero))
		[Utility promptMessageOnScreen:NSLocalizedString(@"Please fill all the fields", nil) sender:self];
	
	// case: fileds are not empty
	else
	{
		NSDictionary* personDetailsDict = @{ kUserIdKey :_usernameTextField.text,
											 kUserpasswordKey:_passwordTextField.text
											};
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:personDetailsDict[kUserIdKey] forKey:kUserIdKey];
		[userDefaults setObject:personDetailsDict[kUserpasswordKey] forKey:kUserpasswordKey];
		
		// method will save user details in NSUserDefault
		[[DataSession initWithDataSession] saveLoginCredentials:[[Person alloc] initWithPerson:personDetailsDict]];
		
		[kChatManagerSingletonObj connect];
	}
}

#pragma mark- NSNotification center method
-(void) checkLoggingIn:(NSNotification* )flag
{
	BOOL loggedIn = [[flag object] boolValue];
	
	if(loggedIn)
		[self performSegueWithIdentifier:kLoginToFrndListSegue sender:self];
	else
		[Utility promptMessageOnScreen:NSLocalizedString(@"Please try after sometime", nil) sender:self];
}

@end
