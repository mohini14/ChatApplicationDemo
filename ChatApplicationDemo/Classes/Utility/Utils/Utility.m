//
//  Utility.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "Utility.h"

@implementation Utility

+(NSString* )getCurrentDateAndTime
{
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm a"];
	
	return [dateFormatter stringFromDate:[NSDate date]];
}

#pragma mark - Alert Manager methods
//This method displays message on screen with proper msg
+ (void)promptMessageOnScreen:(NSString *)message sender:(UIViewController*)sender
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AppName", nil) message:message
															preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:ok];
	[sender presentViewController:alert animated:YES completion:nil];
}

@end
