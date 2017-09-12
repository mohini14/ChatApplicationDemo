//
//  ChatViewController.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDelegate.h"
#import "JSMessagesViewController.h"

@interface ChatViewController : JSMessagesViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) Person* buddy;

@end
