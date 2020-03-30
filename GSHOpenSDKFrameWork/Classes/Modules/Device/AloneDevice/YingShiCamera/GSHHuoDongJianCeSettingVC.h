//
//  GSHHuoDongJianCeSettingVC.h
//  SmartHome
//
//  Created by gemdale on 2018/8/10.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZOpenSDKFramework/EZOpenSDKFramework.h>

@interface GSHHuoDongJianCeSettingVC : UIViewController
+(instancetype)huoDongJianCeSettingVCWithDevice:(GSHDeviceM*)device ipc:(NSMutableDictionary*)ipc;
@end
