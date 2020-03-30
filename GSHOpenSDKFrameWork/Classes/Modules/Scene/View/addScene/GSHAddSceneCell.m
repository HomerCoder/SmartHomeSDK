//
//  GSHAddSceneCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/16.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAddSceneCell.h"

@implementation GSHAddSceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.sceneBackImageView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
