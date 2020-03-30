//
//  GSHConfigWifiInfoVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/18.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSHConfigWifiInfoVC : UIViewController
+(instancetype)configWifiInfoVCWithDeviceM:(GSHDeviceM*)device;
+(instancetype)configWifiInfoVCWithGW:(NSString *)gwId;
@end
