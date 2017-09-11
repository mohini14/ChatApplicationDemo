//
//  HeaderView.h
//  ChatApplicationDemo
//
//  Created by Mohini Sindhu  on 11/09/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


-(UIView* ) setHeaderTitleForTableSection: (NSString* )title;

@end
