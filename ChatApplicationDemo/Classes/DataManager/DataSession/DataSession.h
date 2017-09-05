//
//  DataSession.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface DataSession : NSObject

+(instancetype) initWithDataSession;

-(void) saveLoginCredentials:(Person* )PersonData;

@end
