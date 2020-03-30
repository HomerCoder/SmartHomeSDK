//
//  GSHMessageCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/8.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHMessageCell.h"

@implementation GSHMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
        
    self.messageView.layer.shadowColor = [UIColor blackColor].CGColor;
    // 阴影偏移，默认(0, -3)
    self.messageView.layer.shadowOffset = CGSizeMake(0,3);
    // 阴影透明度，默认0
    self.messageView.layer.shadowOpacity = 0.05;
    // 阴影半径，默认3
    self.messageView.layer.shadowRadius = 5;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
