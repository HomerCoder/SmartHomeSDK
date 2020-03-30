//
//  GSHRecommendSceneCell.m
//  SmartHome
//
//  Created by zhanghong on 2019/11/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHRecommendSceneCell.h"

@implementation GSHRecommendSceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)activeButtonClick:(id)sender {
    if (self.activeButtonClickBlock) {
        self.activeButtonClickBlock();
    }
}

@end
