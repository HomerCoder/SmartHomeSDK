//
//  GSHAPConfigWifiInfoVC.m
//  SmartHome
//
//  Created by gemdale on 2019/5/23.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAPConfigWifiInfoVC.h"
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>
#import "GSHYingShiDeviceWifiLinkVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GSHAddGWApWifiLinkVC.h"

@interface GSHAPConfigWifiInfoVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblWifiName;
@property (weak, nonatomic) IBOutlet UILabel *lblWifiPassword;
- (IBAction)touchCopy:(UIButton *)sender;
- (IBAction)touchNext:(UIButton *)sender;
@property(nonatomic,copy)NSString *gwId;
@property(nonatomic,strong)GSHDeviceM *device;
@property (copy, nonatomic)NSString *wifiName;
@property (copy, nonatomic)NSString *wifiPassWord;
@end

@implementation GSHAPConfigWifiInfoVC

+(instancetype)apConfigWifiInfoVCWithDeviceM:(GSHDeviceM*)device wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord{
    GSHAPConfigWifiInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHAPConfigWifiInfoVC"];
    vc.device = device;
    vc.wifiName = wifiName;
    vc.wifiPassWord = wifiPassWord;
    return vc;
}

+(instancetype)apConfigWifiInfoVCWithGW:(NSString *)gwId wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord{
    GSHAPConfigWifiInfoVC *vc = [GSHPageManager viewControllerWithSB:@"GSHAddYingShiDeviceSB" andID:@"GSHAPConfigWifiInfoVC"];
    vc.gwId = gwId;
    vc.wifiName = wifiName;
    vc.wifiPassWord = wifiPassWord;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.gwId) {
        NSString *str = self.gwId.length > 4 ? [self.gwId substringFromIndex:self.gwId.length - 4] : self.gwId;
        self.lblWifiName.text = [NSString stringWithFormat:@"Gemdale_Gw%@",str ];
        self.lblWifiPassword.text = [NSString stringWithFormat:@"Gemdale%@",str];
    }else{
        self.lblWifiName.text = [NSString stringWithFormat:@"EZVIZ_%@",self.device.deviceSn];
        self.lblWifiPassword.text = [NSString stringWithFormat:@"EZVIZ_%@",self.device.validateCode];
    }
    [self observerNotifications];
}

-(void)dealloc{
    [self removeNotifications];
}

-(void)observerNotifications{
    [self observerNotification:UIApplicationDidBecomeActiveNotification];
}

-(void)handleNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        if (self == [UIViewController visibleTopViewController]) {
            NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
            for (NSString *ifnam in interfaces){
                NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
                NSString *SSID = info[@"SSID"];
                
                if (self.gwId) {
                    NSString *str = self.gwId.length > 4 ? [self.gwId substringFromIndex:self.gwId.length - 4] : self.gwId;
                    if ([SSID isKindOfClass:NSString.class] && [SSID isEqualToString:[NSString stringWithFormat:@"Gemdale_Gw%@",str]]) {
                        GSHAddGWApWifiLinkVC *vc = [GSHAddGWApWifiLinkVC addGWApWifiLinkVCWithSN:self.gwId wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
                        [self.navigationController pushViewController:vc animated:YES];
                        return;
                    }
                }else{
                    if ([SSID isKindOfClass:NSString.class] && [SSID isEqualToString:[NSString stringWithFormat:@"EZVIZ_%@",self.device.deviceSn]]) {
                        GSHYingShiDeviceWifiLinkVC *vc = [GSHYingShiDeviceWifiLinkVC configWifiLinkVCWithDevice:self.device type:GSHYingShiDeviceWifiLinkVCTypeAP wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
                        [self.navigationController pushViewController:vc animated:YES];
                        return;
                    }
                }
            }
        }
    }
}

- (IBAction)touchCopy:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.gwId) {
        NSString *str = self.gwId.length > 4 ? [self.gwId substringFromIndex:self.gwId.length - 4] : self.gwId;
        pasteboard.string = [NSString stringWithFormat:@"Gemdale%@",str];
    }else{
        pasteboard.string = [NSString stringWithFormat:@"EZVIZ_%@",self.device.validateCode];
    }
}

- (IBAction)touchNext:(UIButton *)sender {
    if (self.gwId) {
        GSHAddGWApWifiLinkVC *vc = [GSHAddGWApWifiLinkVC addGWApWifiLinkVCWithSN:self.gwId wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        GSHYingShiDeviceWifiLinkVC *vc = [GSHYingShiDeviceWifiLinkVC configWifiLinkVCWithDevice:self.device type:GSHYingShiDeviceWifiLinkVCTypeAP wifiName:self.wifiName wifiPassWord:self.wifiPassWord];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
