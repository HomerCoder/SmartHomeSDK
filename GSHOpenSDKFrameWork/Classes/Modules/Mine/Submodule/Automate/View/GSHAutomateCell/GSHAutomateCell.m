//
//  GSHAutomateCell.m
//  SmartHome
//
//  Created by zhanghong on 2018/5/9.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHAutomateCell.h"

@interface GSHAutomateCell ()

@property (weak, nonatomic) IBOutlet UILabel *autoNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *leftTimeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftDeviceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightTimeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightDeviceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;

@end

@implementation GSHAutomateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAutoCellValueWithOssAutoM:(GSHOssAutoM *)ossAutoM {
    
    self.autoNameLabel.text = ossAutoM.name;
    self.openSwitch.on = [ossAutoM.status intValue];
//    self.openSwitch.enabled = [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN ? NO : YES;
    self.moreButton.hidden = [GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN ? YES : NO;
     
    int type = ossAutoM.type.intValue;
    self.leftTimeImageView.hidden = (type == 1 || type == 2 || type == 6 || type == 7) ? NO : YES;
    self.leftDeviceImageView.hidden = (type == 0 || type == 2 || type == 3 || type == 4 || type == 5 || type == 7) ? NO : YES;
    self.linkImageView.hidden = (type == 3 || type == 4 || type == 5 || type == 6 || type == 7) ? NO : YES;
    self.rightTimeImageView.hidden = (type == 4 || type == 5) ? NO : YES;
    self.rightDeviceImageView.hidden = (type == 3 || type == 5 || type == 6 || type == 7) ? NO : YES;
}

- (IBAction)openSwitchClick:(UISwitch *)openSwitch {
    if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
        return;
    }
    if (self.openSwitchClickBlock) {
        self.openSwitchClickBlock(openSwitch);
    }
}

- (BOOL)isContainTimeConditionWithConditionList:(NSArray *)conditionList {
    BOOL isContain = NO;
    for (int i = 0; i < conditionList.count; i ++) {
        GSHAutoTriggerConditionListM *conditionListM = conditionList[i];
        if (conditionListM.getDateTimer.length > 0) {
            isContain = YES;
        }
    }
    return isContain;
}

- (IBAction)moreButtonClick:(id)sender {
    if (self.moreButtonClickBlock) {
        self.moreButtonClickBlock();
    }
}



@end
