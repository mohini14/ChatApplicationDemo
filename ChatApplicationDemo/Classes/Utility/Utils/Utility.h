//
//  Utility.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+(NSString* ) getCurrentDateAndTime;

+ (void)promptMessageOnScreen:(NSString *)message sender:(UIViewController*)sender;

@end
