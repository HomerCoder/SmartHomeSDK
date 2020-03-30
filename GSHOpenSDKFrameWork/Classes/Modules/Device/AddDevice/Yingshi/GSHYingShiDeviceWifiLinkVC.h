//
//  GSHYingShiDeviceWifiLinkVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/18.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+TZM.h"

typedef enum : NSUInteger {
    GSHYingShiDeviceWifiLinkVCTypeWIFI,
    GSHYingShiDeviceWifiLinkVCTypeWAVE,
    GSHYingShiDeviceWifiLinkVCTypeAP,
} GSHYingShiDeviceWifiLinkVCType;

@interface GSHYingShiDeviceWifiLinkVC : UIViewController
+(instancetype)configWifiLinkVCWithDevice:(GSHDeviceM*)device type:(GSHYingShiDeviceWifiLinkVCType)type wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord;
@end
