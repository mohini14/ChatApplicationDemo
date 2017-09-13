
//
//  ResgistrationViewController.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 13/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "ResgistrationViewController.h"
#import "Define.h"
//@import XMPPFramework;

@interface ResgistrationViewController ()
{
	IBOutlet UITextField* _userNameTextField;
	IBOutlet UITextField* _passwordTextField;
	IBOutlet UITextField* _confirmpasswordtextField;
	
	ChatManager* _chatmanager;
}

@end

@implementation ResgistrationViewController


#pragma mark- View life cycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initialViewSettings];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Initial view settings
-(void) initialViewSettings
{
	_chatmanager = kChatManagerSingletonObj;
}
- (IBAction)signUpButtonPressed:(UIButton *)sender
{
	NSString* userName = _userNameTextField.text;
	NSString* password = _passwordTextField.text;
	NSString* confirmPassword = _confirmpasswordtextField.text;
	if([self validateFields:userName andPassword:password withConfirmPassword:confirmPassword])
	{
		NSMutableArray *elements = [NSMutableArray array];
		[elements addObject:[NSXMLElement elementWithName:@"username" stringValue:userName]];
		[elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password]];
//		[elements addObject:[NSXMLElement elementWithName:@"name" stringValue:@"eref defg"]];
//		[elements addObject:[NSXMLElement elementWithName:@"accountType" stringValue:@"3"]];
//		[elements addObject:[NSXMLElement elementWithName:@"deviceToken" stringValue:@"adfg3455bhjdfsdfhhaqjdsjd635n"]];
//		
//		[elements addObject:[NSXMLElement elementWithName:@"email" stringValue:@"abc@bbc.com"]];
		
		
		[_chatmanager registerWithElements:elements andUserName:userName andPassword:password];
		
		_chatmanager.recieveRegistrationMessage = ^(NSString* error)
		{
			NSString* message;
			if(!error)
				message = @"successfully registered";
			else
				message = error;
			
			[Utility promptMessageOnScreen:message sender:self];
		};
	}
}


-(BOOL) validateFields: (NSString* )userName andPassword: (NSString* )password withConfirmPassword: (NSString* )confirmPassword
{
	if ((userName.length > kConstIntZero) && [self passwordMatchesWithConfirmPassword:password withConfirmPassword:confirmPassword])
	return true;
	
	[Utility promptMessageOnScreen:@"please fill all the fileds correctly" sender:self];
	return false;
}

-(BOOL)passwordMatchesWithConfirmPassword:(NSString* )password withConfirmPassword:(NSString* )confirmpassword
{
	return [password isEqualToString: confirmpassword];
}

@end
