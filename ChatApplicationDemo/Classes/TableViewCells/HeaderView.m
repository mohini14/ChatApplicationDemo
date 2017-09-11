//
//  HeaderView.m
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 11/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "HeaderView.h"


@implementation HeaderView

-(UIView* ) setHeaderTitleForTableSection:(NSString *)title
{
	self.statusLabel.text = title;
	return self;
}

@end
