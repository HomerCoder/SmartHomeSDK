//
//  GSHVoiceKeyWordHeadView.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/15.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHVoiceKeyWordHeadView.h"

@implementation GSHVoiceKeyWordHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addButton.layer.cornerRadius = self.addButton.frame.size.height / 2.0;
    self.flagView.layer.cornerRadius = 2.0f;
}

- (IBAction)addButtonClick:(id)sender {
    if (self.addButtonClickBlock) {
        self.addButtonClickBlock(self.keyWordTextField.text);
    }
}


@end
