//
//  GSHYingShiDeviceCategoryVC.h
//  SmartHome
//
//  Created by gemdale on 2018/7/30.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GSHYingShiDeviceCategoryVCTypeSheXiangJi,                   //摄像机普通引导
    GSHYingShiDeviceCategoryVCTypeSheXiangJiAP,                 //摄像机AP引导
    GSHYingShiDeviceCategoryVCTypeSheXiangJiReset,              //摄像机普通重置引导
    GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset2,           //摄像机普通配网错误后进入的重置页
    GSHYingShiDeviceCategoryVCTypeSheXiangJiAPReset,            //摄像机AP引导页进入的重置页
    GSHYingShiDeviceCategoryVCTypeMaoYan,                       //猫眼配网引导
} GSHYingShiDeviceCategoryVCType;

@interface GSHYingShiDeviceCategoryVC : UIViewController
+(instancetype)yingShiDeviceCategoryVCWithDevice:(GSHDeviceM*)device type:(GSHYingShiDeviceCategoryVCType)type wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord;
@end
