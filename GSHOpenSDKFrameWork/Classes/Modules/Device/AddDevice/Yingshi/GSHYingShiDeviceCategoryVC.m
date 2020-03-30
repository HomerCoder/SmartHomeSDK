//
//  GSHYingShiDeviceCategoryVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHConfigWifiInfoVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHBlueRoundButton.h"
#import "GSHYingShiDeviceEditVC.h"
#import "GSHYingShiDeviceWifiLinkVC.h"
#import "GSHAPConfigWifiInfoVC.h"

@interface GSHYingShiDeviceCategoryVC ()
- (IBAction)touchHelp:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnNext;
@property (strong, nonatomic)GSHDeviceM *device;
@property (assign, nonatomic)GSHYingShiDeviceCategoryVCType type;
@property (copy,nonatomic)NSString *wifiName;
@property (copy,nonatomic)NSString *wifiPassWord;
@end

@implementation GSHYingShiDeviceCategoryVC

+(instancetype)yingShiDeviceCategoryVCWithDevice:(GSHDeviceM*)device type:(GSHYingShiDeviceCategoryVCType)type wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord{
    GSHYingShiDeviceCategoryVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceCategoryVC"];
    vc.device = device;
    vc.wifiPassWord = wifiPassWord;
    vc.wifiName = wifiName;
    vc.type = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type == GSHYingShiDeviceCategoryVCTypeMaoYan) {
        self.imageView.image = [UIImage ZHImageNamed:@"deviceCategroy_yingshi_guide-3"];
        self.lblText.text = @"请在智能猫眼上进行一下操作：";
        self.title = @"网络配置";
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
        [self.btnNext setTitle:@"wi-fi已连接好" forState:UIControlStateNormal];
    }else if(self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJi){
        self.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_guide_%@",self.device.deviceModelStr]];
        self.lblText.text = @"请将设备插上电源，然后耐心等待约1分钟，直到指示灯红蓝交替闪烁";
        [self.btnNext setTitle:@"指示灯已红蓝交替闪烁" forState:UIControlStateNormal];
        
        self.title = @"网络配置";
        self.line.hidden = NO;
        self.btnReset.hidden = NO;
        [self.btnReset setTitle:@"指示灯未红蓝交替闪烁" forState:UIControlStateNormal];
    }else if(self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJiReset){
        self.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_reset_%@",self.device.deviceModelStr]];
        self.lblText.text = @"请长按设备Reset键10s，直到指示灯红蓝闪烁，即重置成功";
        [self.btnNext setTitle:@"指示灯已红蓝交替闪烁" forState:UIControlStateNormal];

        self.title = @"重置设备";
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
    }else if(self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJiAP){
        self.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_guide_%@",self.device.deviceModelStr]];
        self.lblText.text = @"请将设备插上电源，然后耐心等待约1分钟，直到指示呈蓝色快速闪烁";
        [self.btnNext setTitle:@"指示灯已快速闪烁" forState:UIControlStateNormal];
        
        self.title = @"网络配置";
        self.line.hidden = NO;
        self.btnReset.hidden = NO;
        [self.btnReset setTitle:@"指示灯没有快速闪烁" forState:UIControlStateNormal];
    }else if(self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset){
        self.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_reset_%@",self.device.deviceModelStr]];
        self.lblText.text = @"请长按设备reset键10s,直到听到设备播报“重置成功”，然后等待1分钟，短按设备reset键1—3秒，直到听到设备播报“开启热点模式”";
        [self.btnNext setTitle:@"热点模式已开启" forState:UIControlStateNormal];
        
        self.title = @"重置设备";
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
    }else if(self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset2){
        self.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_reset_%@",self.device.deviceModelStr]];
        self.lblText.text = @"请长按设备reset键10s,直到听到设备播报“重置成功”，然后等待1分钟";
        [self.btnNext setTitle:@"热点模式已开启" forState:UIControlStateNormal];
        
        self.title = @"重置设备";
        self.line.hidden = YES;
        self.btnReset.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchHelp:(UIButton *)sender {
    GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:self.device type:self.type + 2 wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchNext:(UIButton *)sender {
    if (self.device.deviceType.integerValue == 15) {
        __weak typeof(self)weakSelf = self;
        [TZMProgressHUDManager showWithStatus:@"检测中" inView:self.view];
        [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (deviceInfo.status == 1) {
                GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:weakSelf.device];
                [weakSelf.navigationController pushViewController:deviceEditVC animated:YES];
            }else{
                if (!error) {
                    [TZMProgressHUDManager showErrorWithStatus:@"设备不在线" inView:weakSelf.view];
                }else{
                    [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
                }
            }
        }];
    }else{
        if (self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJiReset || self.type == GSHYingShiDeviceCategoryVCTypeSheXiangJi) {
            GSHYingShiDeviceWifiLinkVC *vc = [GSHYingShiDeviceWifiLinkVC configWifiLinkVCWithDevice:self.device type:GSHYingShiDeviceWifiLinkVCTypeWIFI wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            GSHAPConfigWifiInfoVC *vc = [GSHAPConfigWifiInfoVC apConfigWifiInfoVCWithDeviceM:self.device wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
@end
