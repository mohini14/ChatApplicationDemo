//
//  MessageDelegate.h
//  ChatApplicationDemo
//
//  Created by Mohini on 05/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessageDelegate <NSObject>

-(void) newMessageRecieved : (NSDictionary* )messageContent;

@end
