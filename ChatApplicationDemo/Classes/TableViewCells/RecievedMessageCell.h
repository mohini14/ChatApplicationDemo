//
//  SenderMessageTableCell.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface RecievedMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageSenderNameLabel;

-(void) setUpcellAttributes : (Person* )messageData;

@end
