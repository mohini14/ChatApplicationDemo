//
//  Messages.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString* messageData;
@property (strong, nonatomic) NSDate* messadgeDate;
@property (strong, nonatomic) NSString* messageType;
@property (strong, nonatomic) NSString* Image;

//-(instancetype) initWithMessage: (NSString* )messageData withDate: (NSString* )date forMediaTyoe:(NSString* )mediaType withImage:(NSString* )image;

@end
