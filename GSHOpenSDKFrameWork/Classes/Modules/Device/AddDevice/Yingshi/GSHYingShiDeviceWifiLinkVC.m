//
//  GSHYingShiDeviceWifiLinkVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/18.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHYingShiDeviceWifiLinkVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHYingShiDeviceEditVC.h"
#import "GSHBlueRoundButton.h"
#import "GSHYingShiCameraVC.h"
#import "GSHYingShiDeviceCategoryVC.h"
#import "GSHConfigWifiInfoVC.h"

@interface GSHYingShiDeviceWifiLinkVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewState;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnState;
@property (weak, nonatomic) IBOutlet UIView *viewState;
@property (weak, nonatomic) IBOutlet GSHBlueRoundButton *btnAP;
- (IBAction)touchState:(UIButton *)sender;
- (IBAction)touchAP:(UIButton *)sender;

@property (assign, nonatomic)GSHYingShiDeviceWifiLinkVCType type;
@property (copy, nonatomic)NSString *wifiName;
@property (copy, nonatomic)NSString *wifiPassWord;
@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)NSTimer *timer;
@end

@implementation GSHYingShiDeviceWifiLinkVC

+(instancetype)configWifiLinkVCWithDevice:(GSHDeviceM*)device type:(GSHYingShiDeviceWifiLinkVCType)type wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord;{
    GSHYingShiDeviceWifiLinkVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHYingShiDeviceWifiLinkVC"];
    vc.type = type;
    vc.wifiName = wifiName;
    vc.wifiPassWord = wifiPassWord;
    vc.device = device;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self networking];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldHoldBackButtonEvent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkStatus) object:nil];
    return NO;
}

-(void)dealloc{
    [EZOpenSDK stopConfigWifi];
    [EZOpenSDK stopAPConfigWifi];
    [self.timer invalidate];
}

- (void)initUI{
    if (self.device) {
        self.imageViewIcon.image = [UIImage ZHImageNamed:@"deviceCategroy_yingshi_network_icon-1"];
    }
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 6.0 block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.pageControl.numberOfPages == weakSelf.pageControl.currentPage + 1) {
            weakSelf.pageControl.currentPage = 0;
        }else{
            weakSelf.pageControl.currentPage++;
        }
    } repeats:YES];
    
    if (weakSelf.type == GSHYingShiDeviceWifiLinkVCTypeAP) {
        return;
    }
    [GSHYingShiManager getCheckAPAvailableWithModelName:self.device.deviceModelStr block:^(id responseObject, NSError *error) {
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSNumber *apAvailable = [(NSDictionary*)responseObject objectForKey:@"apAvailable"];
            if ([apAvailable isKindOfClass:NSNumber.class]) {
                weakSelf.btnAP.hidden = apAvailable.intValue == 0;
            }
        }
    }];
}

- (void)networking{
    __weak typeof(self)weakSelf = self;
    if (self.type == GSHYingShiDeviceWifiLinkVCTypeAP){
        [self performSelector:@selector(checkStatus) withObject:nil afterDelay:60];
        [EZOpenSDK startAPConfigWifiWithSsid:self.wifiName password:self.wifiPassWord deviceSerial:self.device.deviceSn verifyCode:self.device.validateCode result:^(BOOL ret) {
            if (ret) {
                [weakSelf refreshDeviceStatus:DEVICE_WIFI_CONNECTING deviceSerial:weakSelf.device.deviceSn];
            }
        }];
    }else if (self.type == GSHYingShiDeviceWifiLinkVCTypeWIFI){
        [self performSelector:@selector(checkStatus) withObject:nil afterDelay:60];
        [EZOpenSDK startConfigWifi:self.wifiName password:self.wifiPassWord deviceSerial:self.device.deviceSn mode:EZWiFiConfigSmart deviceStatus:^(EZWifiConfigStatus status, NSString *deviceSerial) {
            [weakSelf refreshDeviceStatus:status deviceSerial:deviceSerial];
        }];
    }else{
        [self performSelector:@selector(checkStatus) withObject:nil afterDelay:60];
        [EZOpenSDK startConfigWifi:self.wifiName password:self.wifiPassWord deviceSerial:self.device.deviceSn mode:EZWiFiConfigWave deviceStatus:^(EZWifiConfigStatus status, NSString *deviceSerial) {
            [weakSelf refreshDeviceStatus:status deviceSerial:deviceSerial];
        }];
    }
}

- (void)refreshDeviceStatus:(EZWifiConfigStatus) status deviceSerial:(NSString*)deviceSerial{
    NSLog(@"status = %d",(int)status);
    if (status == DEVICE_WIFI_CONNECTING){
//        self.lblText.text = @"设备正在连接WiFi";
    }else if (status == DEVICE_WIFI_CONNECTED){
//        self.lblText.text = @"设备连接WiFi成功";
    }else if (status == DEVICE_PLATFORM_REGISTED){
//        self.lblText.text = @"设备注册平台成功";
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkStatus) object:nil];
        [self next:nil];
    }else{
        if (self.device.roomId) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkStatus) object:nil];
            [self next:nil];
        }
    }
}

-(void)checkStatus{
    __weak typeof(self)weakSelf = self;
    [EZOpenSDK stopConfigWifi];
    [EZOpenSDK stopAPConfigWifi];
    [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
        if (error) {
            if (error.code == EZ_HTTPS_DEVICE_ONLINE_NOT_ADDED || error.code == EZ_HTTPS_DEVICE_ONLINE_ADDED) {
                //设备在线未被用户添加
                [weakSelf next:nil];
            }else{
                weakSelf.title = @"网络配置失败";
                weakSelf.lblState.text = error.localizedDescription;
                [weakSelf.btnState setTitle:@"重试" forState:UIControlStateNormal];
                weakSelf.imageViewState.image =[UIImage ZHImageNamed:@"app_icon_error_red"];
                weakSelf.viewState.hidden = NO;
                if(error.code == EZ_HTTPS_ACCESS_TOKEN_INVALID ||
                   error.code == EZ_HTTPS_ACCESS_TOKEN_EXPIRE){
                    //token错误
                    [GSHYingShiManager updataAccessTokenWithBlock:NULL];
                }
            }
        }else{
            //未报错
            [weakSelf next:nil];
        }
    }];
}

- (void)next:(UIButton *)sender {
    if (self.device.roomId) {
        [EZOpenSDK stopConfigWifi];
        [EZOpenSDK stopAPConfigWifi];
        self.title = @"网络配置成功";
        self.lblState.text = @"网络配置成功";
        [self.btnState setTitle:@"返回设备首页" forState:UIControlStateNormal];
        self.btnAP.hidden = YES;
        self.imageViewState.image = [UIImage ZHImageNamed:@"app_icon_susess"];
        self.viewState.hidden = NO;
        self.navigationItem.hidesBackButton = YES;
    }else{
        [EZOpenSDK stopConfigWifi];
        [EZOpenSDK stopAPConfigWifi];
        GSHYingShiDeviceEditVC *deviceEditVC = [GSHYingShiDeviceEditVC yingShiDeviceEditVCWithDevice:self.device];
        [self.navigationController pushViewController:deviceEditVC animated:YES];
    }
}
- (IBAction)touchState:(UIButton *)sender {
    if (self.navigationItem.hidesBackButton) {
        NSMutableArray *arr = [NSMutableArray array];
        for (UIViewController *vc in self.navigationController.viewControllers) {
            [arr addObject:vc];
            if ([vc isKindOfClass:GSHYingShiCameraVC.class]) {
                break;
            }
        }
        [self.navigationController setViewControllers:arr animated:YES];
    }else{
        self.title = @"网络配置中";
        self.viewState.hidden = YES;
        [EZOpenSDK stopConfigWifi];
        [EZOpenSDK stopAPConfigWifi];
        [self networking];
    }
}

- (IBAction)touchAP:(UIButton *)sender {
    GSHYingShiDeviceCategoryVC *yingShiDeviceCategoryVC = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:self.device type:GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
    NSMutableArray *vcs = [NSMutableArray array];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        [vcs addObject:vc];
        if ([vc isKindOfClass:GSHConfigWifiInfoVC.class]) {
            [vcs addObject:yingShiDeviceCategoryVC];
            break;
        }
    }
    [self.navigationController setViewControllers:vcs animated:YES];
}
@end
