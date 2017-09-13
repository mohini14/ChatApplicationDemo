
//
//  NSString+ChatApplicationDemo.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 06/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "NSString+ChatApplicationDemo.h"

@implementation NSString (ChatApplicationDemo)


+ (NSString *) getCurrentTime {
	
	NSDate *nowUTC = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:nowUTC];
	
}



//	//See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
//	
//	NSString *res = [self stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];
//	res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
//	res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
//	res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
//	
//	return res;

//}
@end
