//
//  SenderMessageTableCell.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 04/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "RecievedMessageCell.h"

@implementation RecievedMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setUpcellAttributes:(Person *)messageData
{
	self.messageTextLabel.text = messageData.message.messageData;
	self.messageTimeLabel.text = [messageData.message.messadgeDate xmppDateString];
	self.messageSenderNameLabel.text = messageData.name;
}
@end
