//
//  GSHAPConfigWifiInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2019/5/23.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHAPConfigWifiInfoVC : UIViewController
+(instancetype)apConfigWifiInfoVCWithDeviceM:(GSHDeviceM*)device wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord;
+(instancetype)apConfigWifiInfoVCWithGW:(NSString *)gwId wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord;
@end

