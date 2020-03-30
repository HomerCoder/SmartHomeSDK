//
//  GSHYingShiDeviceDetailVC.m
//  SmartHome
//
//  Created by gemdale on 2018/8/24.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceDetailVC.h"
#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHAlertManager.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHYingShiDeviceEditVC.h"
#import "GSHConfigWifiInfoVC.h"
#import <AFNetworking.h>

@interface GSHYingShiDeviceDetailVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
- (IBAction)touchNext:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)GSHDeviceModelM *model;
@end

@implementation GSHYingShiDeviceDetailVC

+(instancetype)yingShiDeviceDetailVCWithDevice:(GSHDeviceM*)device model:(GSHDeviceModelM*)model{
    GSHYingShiDeviceDetailVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceDetailVC"];
    vc.device = device;
    vc.model = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [GSHYingShiManager updataAccessTokenWithBlock:NULL];
    // Do any additional setup after loading the view.
    self.lblName.text = [NSString stringWithFormat:@"%@(%@)",self.device.deviceModelStr,self.device.deviceSn];
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"检测设备是否可用" inView:self.view];
    [GSHYingShiManager getIsDeviceAddableWithDeviceSerial:self.device.deviceSn modelName:self.device.deviceModelStr familyId:[GSHOpenSDKShare share].currentFamily.familyId block:^(NSDictionary *data, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        if (error) {
            weakSelf.lblContent.text = error.localizedDescription;
            weakSelf.lblContent.hidden = NO;
            weakSelf.btnNext.hidden = YES;
        }else{
            weakSelf.lblContent.hidden = YES;
            weakSelf.btnNext.hidden = NO;
            weakSelf.device.deviceModelStr = [data stringValueForKey:@"modelName" default:nil];
            weakSelf.device.deviceModel = [data numverValueForKey:@"ipcModel" default:nil];
            weakSelf.device.deviceType = [data numverValueForKey:@"deviceType" default:nil];
            weakSelf.device.manufacturer = [data stringValueForKey:@"manufacturer" default:nil];
            weakSelf.device.agreementType = [data stringValueForKey:@"agreementType" default:nil];
            if (weakSelf.device.deviceType.integerValue == 15) {
                weakSelf.imageView.image = [UIImage ZHImageNamed:@"deviceCategroy_yingshi_detail-3"];
            }else if (weakSelf.device.deviceType.integerValue == 17 || weakSelf.device.deviceType.integerValue == 16) {
                weakSelf.imageView.image = [UIImage ZHImageNamed:[NSString stringWithFormat:@"deviceCategroy_yingshi_detail_%@",weakSelf.device.deviceModelStr]];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchNext:(UIButton *)sender {
    [TZMProgressHUDManager showInView:self.view];
    __weak typeof(self)weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        if (deviceInfo.status == 1) {
            GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:weakSelf.device];
            [weakSelf.navigationController pushViewController:deviceEditVC animated:YES];
        }else{
            if (weakSelf.device.deviceType.integerValue == 15) {
                GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:weakSelf.device type:GSHYingShiDeviceCategoryVCTypeMaoYan wifiName:nil wifiPassWord:nil];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (weakSelf.device.deviceType.integerValue == 17 || weakSelf.device.deviceType.integerValue == 16) {
                if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
                    GSHConfigWifiInfoVC *vc = [GSHConfigWifiInfoVC configWifiInfoVCWithDeviceM:weakSelf.device];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }else{
                    [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
                        
                    } textFieldsSetupHandler:NULL andTitle:@"请先连接到路由器的wifi" andMessage:@"请在iphone的\"设置\"-\" wifi\"中选择一个可用的wifi热点接入后再点击\"下一步\"按钮" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了",nil];
                }
            }
        }
    }];
}
@end
