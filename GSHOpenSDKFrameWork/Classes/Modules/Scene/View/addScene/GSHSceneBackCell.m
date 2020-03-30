//
//  GSHSceneBackCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHSceneBackCell.h"

@implementation GSHSceneBackCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.sceneBackImageView.layer.cornerRadius = 5.0f;
    self.checkBoxImageView.hidden = YES;
}

@end
