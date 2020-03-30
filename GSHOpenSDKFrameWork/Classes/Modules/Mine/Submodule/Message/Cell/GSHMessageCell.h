//
//  GSHMessageCell.h
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageNameLabel;
@property (weak, nonatomic) IBOutlet UIView *shortLineView;



@end
