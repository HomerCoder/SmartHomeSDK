//
//  GSHConfigWifiInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2018/7/18.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHConfigWifiInfoVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GSHYingShiDeviceWifiLinkVC.h"
#import "GSHWebViewController.h"
#import "GSHAlertManager.h"
#import "NSObject+TZM.h"
#import "GSHYingShiDeviceCategoryVC.h"
#import <CoreLocation/CoreLocation.h>
#import "GSHAddGWApSettingVC.h"

NSString *const GSHConfigWifiInfoDic = @"GSHConfigWifiInfoDic";

@interface GSHConfigWifiInfoVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfWifiName;
@property (weak, nonatomic) IBOutlet UITextField *tfWifiPassWord;
- (IBAction)showPassword:(UIButton *)sender;
- (IBAction)configWifi:(UIButton *)sender;
- (IBAction)touchWhy:(UIButton *)sender;

@property (strong, nonatomic)GSHDeviceM *device;
@property (strong, nonatomic)NSString *gwId;
@property (copy, nonatomic)NSString *mac;

@property (strong, nonatomic) CLLocationManager* locationManager;
@end

@implementation GSHConfigWifiInfoVC

+(instancetype)configWifiInfoVCWithDeviceM:(GSHDeviceM*)device{
    GSHConfigWifiInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHConfigWifiInfoVC"];
    vc.device = device;
    return vc;
}

+(instancetype)configWifiInfoVCWithGW:(NSString *)gwId{
    GSHConfigWifiInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHConfigWifiInfoVC"];
    vc.gwId = gwId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [CLLocationManager new];
    // Do any additional setup after loading the view.
    [self refreshWiFi];
    [self observerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationDidBecomeActiveNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self refreshWiFi];
    }
}

- (void)refreshWiFi{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [GSHAlertManager showAlertWithBlock:^(NSInteger buttonIndex, id alert) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }
        } textFieldsSetupHandler:NULL andTitle:@"智享Home需要使用位置权限，用以扫描WiFi热点" andMessage:@"点击“设置”，允许智享Home使用您的位置" image:nil preferredStyle:GSHAlertManagerStyleAlert destructiveButtonTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:@"设置",nil];
        return;
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [_locationManager requestWhenInUseAuthorization];
        return;
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [TZMProgressHUDManager showWithStatus:@"获取wifi信息中" inView:self.view];
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in interfaces){
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        self.tfWifiName.text = info[@"SSID"];
        self.mac = info[@"BSSID"];
        if (self.tfWifiName.text.length > 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [userDefaults dictionaryForKey:GSHConfigWifiInfoDic];
            NSString *password = [dic stringValueForKey:self.tfWifiName.text default:nil];
            self.tfWifiPassWord.text = password;
            [userDefaults synchronize];
            break;
        }
    }
    [TZMProgressHUDManager dismissInView:self.view];
}

- (IBAction)showPassword:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.tfWifiPassWord.secureTextEntry = !sender.selected;
}

- (IBAction)configWifi:(UIButton *)sender {
    if (self.tfWifiName.text.length == 0) {
        [TZMProgressHUDManager showErrorWithStatus:@"未选择wifi，请点击切换网络并选择要链接的wifi" inView:self.view];
        return;
    }
    if (self.gwId) {
        GSHAddGWApSettingVC *vc = [GSHAddGWApSettingVC addGWApSettingVCWithSn:self.gwId wifiName:self.tfWifiName.text wifiPassWord:self.tfWifiPassWord.text];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [TZMProgressHUDManager showWithStatus:@"检测设备中" inView:self.view];
        __weak typeof(self)weakSelf = self;
        [EZOpenSDK probeDeviceInfo:self.device.deviceSn deviceType:nil completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            GSHYingShiDeviceCategoryVCType type;
            if (weakSelf.device.deviceName.length > 0) {
                if(deviceInfo.supportAP == 2){
                    type = GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset;
                }else{
                    type = GSHYingShiDeviceCategoryVCTypeSheXiangJiReset;
                }
            }else{
                if(deviceInfo.supportAP == 2){
                    type = GSHYingShiDeviceCategoryVCTypeSheXiangJiAP;
                }else{
                    type = GSHYingShiDeviceCategoryVCTypeSheXiangJi;
                }
            }
            GSHYingShiDeviceCategoryVC *vc = [GSHYingShiDeviceCategoryVC yingShiDeviceCategoryVCWithDevice:weakSelf.device type:type wifiName:weakSelf.tfWifiName.text wifiPassWord:weakSelf.tfWifiPassWord.text];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
    }

    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:GSHConfigWifiInfoDic]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setValue:self.tfWifiPassWord.text forKey:self.tfWifiName.text];
    [userDefaults setObject:dic forKey:GSHConfigWifiInfoDic];
    [userDefaults synchronize];
}

- (IBAction)touchWhy:(UIButton *)sender {
    NSURL *url = [GSHWebViewController webUrlWithType:GSHAppConfigH5TypeNorouter parameter:nil];
    [self.navigationController pushViewController:[[GSHWebViewController alloc] initWithURL:url] animated:YES];
}
@end
