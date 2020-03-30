//
//  GSHSensorSetVC.m
//  SmartHome
//
//  Created by zhanghong on 2019/5/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAlarmSensorSetVC.h"
#import "UINavigationController+TZM.h"
#import "GSHDeviceEditVC.h"

@interface GSHAlarmSensorSetVC ()

@property (weak, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *alarmButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (assign, nonatomic) GSHSensorType sensorType;
@property (strong, nonatomic) NSString *alarmMeteId;

@end

@implementation GSHAlarmSensorSetVC

+ (instancetype)alarmSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM
                                 sensorType:(GSHSensorType)sensorType
                             deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHAlarmSensorSetVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAlarmSensorSetSB" andID:@"GSHAlarmSensorSetVC"];
    vc.deviceM = deviceM;
    vc.sensorType = sensorType;
    vc.deviceEditType = deviceEditType;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    self.sensorNameLabel.text = self.deviceM.deviceName;
    [self getDeviceDetailInfo];
    
    if (self.sensorType == GSHSomatasensorySensor) {
        // 红外人体传感器
        self.alarmMeteId = GSHSomatasensorySensor_alarmMeteId;
    } else if (self.sensorType == GSHGateMagetismSensor) {
        // 门磁传感器
        self.alarmMeteId = GSHGateMagetismSensor_isOpenedMeteId;
    } else if (self.sensorType == GSHSmogGasSensor) {
        // 烟雾传感器
        self.alarmMeteId = GSHGasSensor_alarmMeteId;
    } else if (self.sensorType == GSHWaterLoggingSensor) {
        // 水浸传感器
        self.alarmMeteId = GSHWaterLoggingSensor_alarmMeteId;
    } else if (self.sensorType == GSHInfrareCurtainSensor) {
        // 红外幕帘
        self.alarmMeteId = GSHInfrareCurtain_alarmMeteId;
    } else if (self.sensorType == GSHSOSSensor) {
        // 紧急按钮
        self.alarmMeteId = GSHSOSSensor_alarmMeteId;
    } else if (self.sensorType == GSHAudibleVisualAlarmSensor) {
        // 声光报警器
        self.alarmMeteId = GSHAudibleVisualAlarm_alarmMeteId;
        [self.alarmButton setTitle:@"响铃+发光" forState:UIControlStateNormal];
        [self.alarmButton setTitle:@"响铃+发光" forState:UIControlStateSelected];
        if (self.deviceEditType == GSHDeviceVCTypeControl) {
            [self.sureButton setTitle:@"" forState:UIControlStateNormal];
            [self.sureButton setImage:[UIImage ZHImageNamed:@"device_set_btn"] forState:UIControlStateNormal];
            if ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember) {
                // 成员隐藏按钮
                self.sureButton.hidden = YES;
            }
        }
    } else if (self.sensorType == GSHInfrareReactionSensor) {
        // 红外人体感应面板
        self.alarmMeteId = GSHInfrareReaction_alarmMeteId;
    } else if (self.sensorType == GSHCoGasSensor) {
        // 一氧化碳传感器
        self.alarmMeteId = GSHCoGasSensor_alarmMeteId;
    } else if (self.sensorType == GSHCombustibleSensor) {
        // 可燃气体传感器
        self.alarmMeteId = GSHCombustibleGas_alarmMeteId;
    }
        
    if (!(self.deviceEditType == GSHDeviceVCTypeControl && self.sensorType == GSHAudibleVisualAlarmSensor)) {
        // 将声光报警器的控制页面排除在外
        if (self.deviceM.exts.count > 0) {
            GSHDeviceExtM *extM = self.deviceM.exts[0];
            NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
            if (value.intValue == 1) {
                self.alarmButton.selected = YES;
                self.normalButton.selected = NO;
                [self.alarmButton setBackgroundColor:[UIColor whiteColor]];
                [self.normalButton setBackgroundColor:[UIColor clearColor]];
            } else {
                self.alarmButton.selected = NO;
                self.normalButton.selected = YES;
                [self.alarmButton setBackgroundColor:[UIColor clearColor]];
                [self.normalButton setBackgroundColor:[UIColor whiteColor]];
            }
        } else {
            self.alarmButton.selected = NO;
            self.normalButton.selected = YES;
            [self.alarmButton setBackgroundColor:[UIColor clearColor]];
            [self.normalButton setBackgroundColor:[UIColor whiteColor]];
        }
    }
}


#pragma mark - method

- (IBAction)normalButtonClick:(UIButton *)sender {
    
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        [self controlDeviceWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId value:@"0"];
    } else {
        if (sender.selected) {
            return;
        }
        sender.selected = YES;
        self.alarmButton.selected = NO;
        [self.alarmButton setBackgroundColor:[UIColor clearColor]];
        [self.normalButton setBackgroundColor:[UIColor whiteColor]];
    }
}

- (IBAction)alarmButtonClick:(UIButton *)sender {
    
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        [self controlDeviceWithBasMeteId:GSHAudibleVisualAlarm_alarmMeteId value:@"1"];
    } else {
        if (sender.selected) {
            return;
        }
        sender.selected = YES;
        self.normalButton.selected = NO;
        [self.alarmButton setBackgroundColor:[UIColor whiteColor]];
        [self.normalButton setBackgroundColor:[UIColor clearColor]];
    }
    
}

- (IBAction)sureButtonClick:(id)sender {
    if (self.sensorType == GSHAudibleVisualAlarmSensor && self.deviceEditType == GSHDeviceVCTypeControl) {
        // 声光报警器的操作页面
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
            return;
        }
        if (!self.deviceM) {
            [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            self.sensorNameLabel.text = self.deviceM.deviceName;
        };
        [self closeWithComplete:^{
            [[UIViewController visibleTopViewController].navigationController pushViewController:deviceEditVC animated:YES];
        }];
    } else {
        NSMutableArray *exts = [NSMutableArray array];
        // 告警
        NSString *triggerMeteId = self.alarmMeteId;;
        if ([self.deviceM.deviceSn containsString:@"_"]) {
            // 通过组合传感器虚拟出来的传感器
            triggerMeteId = [self.deviceM getBaseMeteIdFromDeviceSn:self.deviceM.deviceSn];
        } else {
            triggerMeteId = self.alarmMeteId;
        }
        NSString *triggerValue = self.alarmButton.selected ? @"1" : @"0";
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

// 设备控制
- (void)controlDeviceWithBasMeteId:(NSString *)basMeteId
                             value:(NSString *)value {
    
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue deviceSN:self.deviceM.deviceSn familyId:[GSHOpenSDKShare share].currentFamily.familyId basMeteId:basMeteId value:value block:^(NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        }
    }];
    
}


@end
