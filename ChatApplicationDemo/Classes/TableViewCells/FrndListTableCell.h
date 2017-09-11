//
//  FrndListTableCell.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ChatDelegate.h"

@interface FrndListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *frndnameLabel;

-(void) setUPCell : (Person* )personDetails;

@end
