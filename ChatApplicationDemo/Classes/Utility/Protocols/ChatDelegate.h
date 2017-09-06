//
//  ChatProtocols.h
//  ChatApplicationDemo
//
//  Created by Mohini on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatDelegate <NSObject>

-(void) newBuddyOnline : (NSString* ) buddyName;
-(void) buddyWentOffline : (NSString* )buddyName;
-(void) didDisconnect;

@end
