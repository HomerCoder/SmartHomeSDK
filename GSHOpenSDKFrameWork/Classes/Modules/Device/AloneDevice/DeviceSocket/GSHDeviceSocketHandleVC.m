//
//  GSHDeviceSocketHandleVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/9/7.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHDeviceSocketHandleVC.h"
#import "UINavigationController+TZM.h"

#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

@interface GSHDeviceSocketHandleVC ()
@property (nonatomic,strong) NSArray *exts;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *electricQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *usbSwitch;
@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIButton *firstCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *usbCheckButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstCheckButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usbCheckButtonLeading;
@property (weak, nonatomic) IBOutlet UIView *viewUSB;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation GSHDeviceSocketHandleVC

+ (instancetype)deviceSocketHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHDeviceSocketHandleVC *vc = [GSHPageManager viewControllerWithSB:@"GSHDeviceSocketHandleSB" andID:@"GSHDeviceSocketHandleVC"];
    vc.deviceEditType = deviceEditType;
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tzm_prefersNavigationBarHidden = YES;
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        [self observerNotifications];
    }
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        self.firstCheckButton.hidden = YES;
        self.usbCheckButton.hidden = YES;
        self.firstCheckButtonLeading.constant = 0;
        self.usbCheckButtonLeading.constant = 0;
        self.openSwitch.alpha = 1;
        self.usbSwitch.alpha = 1;
    }
    
}

-(void)observerNotifications{
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self refreshUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method
- (IBAction)enterDeviceButtonClick:(id)sender {
    if (!self.deviceM) {
        [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
        return;
    }
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            [self refreshUI];
        };
        [self closeWithComplete:^{
            [[UIViewController visibleTopViewController].navigationController pushViewController:deviceEditVC animated:YES];
        }];
    } else {
        NSMutableArray *exts = [NSMutableArray array];
        GSHDeviceExtM *openSwitchExtM = [[GSHDeviceExtM alloc] init];
        openSwitchExtM.basMeteId = [self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_SocketSwitchMeteId : GSHSocket2_SocketSwitchMeteId;
        openSwitchExtM.conditionOperator = @"==";
        openSwitchExtM.rightValue = self.openSwitch.on?@"1":@"0";
        
        GSHDeviceExtM *usbSwitchExtM = [[GSHDeviceExtM alloc] init];
        usbSwitchExtM.basMeteId = GSHSocket1_USBSwitchMeteId;
        usbSwitchExtM.conditionOperator = @"==";
        usbSwitchExtM.rightValue = self.usbSwitch.on?@"1":@"0";
        
        if (self.firstCheckButton.selected) {
            [exts addObject:openSwitchExtM];
        }
        if (self.usbCheckButton.selected) {
            [exts addObject:usbSwitchExtM];
        }
        if (exts.count == 0) {
            [TZMProgressHUDManager showErrorWithStatus:@"请选择插座或USB" inView:self.view];
            return;
        }
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self closeWithComplete:^{
            
        }];
    }
}

- (IBAction)openSwitchClick:(UISwitch *)sender {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *value = [NSString stringWithFormat:@"%d",sender.on];
        [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                                   deviceSN:self.deviceM.deviceSn
                                                   familyId:[GSHOpenSDKShare share].currentFamily.familyId
                                                  basMeteId:[self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_SocketSwitchMeteId : GSHSocket2_SocketSwitchMeteId
                                                      value:value
                                                      block:^(NSError *error) {
              if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                  if (error) {
                      sender.on = !sender.on;
                  }
              }
        }];
    }
}

- (IBAction)usbSwitchClick:(UISwitch *)sender {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *value = [NSString stringWithFormat:@"%d",sender.on];
        [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                                   deviceSN:self.deviceM.deviceSn
                                                   familyId:[GSHOpenSDKShare share].currentFamily.familyId
                                                  basMeteId:GSHSocket1_USBSwitchMeteId
                                                      value:value
                                                      block:^(NSError *error) {
            if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
                if (error) {
                    sender.on = !sender.on;
                } 
            }
        }];
    }
}

- (IBAction)firstCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openSwitch.alpha = sender.selected ? 1 : 0.5;
    self.openSwitch.enabled = sender.selected;
}

- (IBAction)usbCheckButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.usbSwitch.alpha = sender.selected ? 1 : 0.5;
    self.usbSwitch.enabled = sender.selected;
}

- (void)refreshUI {
    self.deviceNameLabel.text = self.deviceM.deviceName;
    
    NSDictionary *dic = [self.deviceM realTimeDic];
    NSLog(@"dic : %@",dic);
    NSString *electricQuantityValue = [dic objectForKey:[self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_ElectricQuantityKey : GSHSocket2_ElectricQuantityKey];
    NSString *powerValue = [dic objectForKey:[self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_PowerKey :GSHSocket2_PowerKey];
    self.viewUSB.hidden = ![self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.deviceM.controlPicPath] placeholderImage:GlobalPlaceHoldImage];
    
    self.electricQuantityLabel.text = electricQuantityValue?[NSString stringWithFormat:@"电量: %.2f KWh",electricQuantityValue.floatValue/100.0] : @"电量: 无数据";
    self.powerLabel.text = powerValue?[NSString stringWithFormat:@"功率: %.1f W",powerValue.floatValue/10.0] : @"功率: 无数据";
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *switchValue = [dic objectForKey:[self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_SocketSwitchMeteId : GSHSocket2_SocketSwitchMeteId];
        self.openSwitch.on = switchValue.intValue == 0 ? NO : YES;
        NSString *usbSwitchValue = [dic objectForKey:GSHSocket1_USBSwitchMeteId];
        self.usbSwitch.on = usbSwitchValue.intValue == 0 ? NO : YES;
    } else {
        if (self.deviceM.exts.count > 0) {
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:[self.deviceM.deviceType isEqualToNumber:GSHSocket1DeviceType] ?  GSHSocket1_SocketSwitchMeteId : GSHSocket2_SocketSwitchMeteId]) {
                    if (extM.rightValue) {
                        self.openSwitch.on = extM.rightValue.intValue == 1 ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.openSwitch.on = extM.param.intValue == 1 ? YES : NO;
                    }
                    self.firstCheckButton.selected = YES;
                    self.openSwitch.alpha = 1;
                } else if ([extM.basMeteId isEqualToString:GSHSocket1_USBSwitchMeteId]) {
                    if (extM.rightValue) {
                        self.usbSwitch.on = extM.rightValue.intValue == 1 ? YES : NO;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        self.usbSwitch.on = extM.param.intValue == 1 ? YES : NO;
                    }
                    self.usbCheckButton.selected = YES;
                    self.usbSwitch.alpha = 1;
                }
            }
        } 
    }
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            self.deviceM = device;
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        } else {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
        }
    }];
}
@end
