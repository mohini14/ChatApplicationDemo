//
//  FrndListViewController.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 31/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrndListTableCell.h"
#import "ChatDelegate.h"

@interface FrndListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ChatDelegate>

@end
