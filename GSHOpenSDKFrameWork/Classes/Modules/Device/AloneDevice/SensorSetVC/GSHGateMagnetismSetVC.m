//
//  GSHGateMagnetismSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/11/12.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHGateMagnetismSetVC.h"
#import "UINavigationController+TZM.h"

@interface GSHGateMagnetismSetVC ()

@property (weak, nonatomic) IBOutlet UIButton *beOpenedButton;
@property (weak, nonatomic) IBOutlet UIButton *beClosedButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;

@end

@implementation GSHGateMagnetismSetVC

+ (instancetype)gateMagnetismSetVCWithDeviceM:(GSHDeviceM *)deviceM {
    GSHGateMagnetismSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHGateMagnetismSetSB" andID:@"GSHGateMagnetismSetVC"];
    vc.deviceM = deviceM;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    self.deviceNameLabel.text = self.deviceM.deviceName;
    
    [self getDeviceDetailInfo];
    
    if (self.deviceM.exts.count > 0) {
        GSHDeviceExtM *extM = self.deviceM.exts[0];
        if (extM.rightValue.intValue == 1) {
            self.beOpenedButton.selected = YES;
            self.beClosedButton.selected = NO;
        } else {
            self.beOpenedButton.selected = NO;
            self.beClosedButton.selected = YES;
        }
    } else {
        self.beOpenedButton.selected = YES;
        self.beClosedButton.selected = NO;
    }
}

#pragma mark - method
- (IBAction)beOpenedButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    self.beClosedButton.selected = NO;
}

- (IBAction)beClosedButtonClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    self.beOpenedButton.selected = NO;
    sender.selected = YES;
}

- (IBAction)sureButtonClick:(id)sender {
    NSMutableArray *exts = [NSMutableArray array];
    // 告警
    NSString *triggerMeteId = GSHGateMagetismSensor_isOpenedMeteId;
    if ([self.deviceM.deviceSn containsString:@"_"]) {
        triggerMeteId = [self.deviceM getBaseMeteIdFromDeviceSn:self.deviceM.deviceSn];
    } else {
        triggerMeteId = GSHGateMagetismSensor_isOpenedMeteId;
    }
    NSString *triggerValue = self.beOpenedButton.selected ? @"1" : @"0";
    GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
    extM.basMeteId = triggerMeteId;
    extM.conditionOperator = @"==";
    extM.rightValue = triggerValue;
    [exts addObject:extM];
    if (self.deviceSetCompleteBlock) {
        self.deviceSetCompleteBlock(exts);
    }
    [self closeWithComplete:^{}];
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            [self.guideImageView sd_setImageWithURL:[NSURL URLWithString:device.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
        }
    }];
}



@end
