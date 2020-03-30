//
//  GSHSensorSetVC.h
//  SmartHome
//
//  Created by zhanghong on 2019/5/7.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHDeviceVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GSHSensorType) {
    GSHSomatasensorySensor   = 0,  // 人体红外传感器
    GSHGateMagetismSensor  = 1, //  门磁传感器
    GSHSmogGasSensor  = 2, //  烟雾传感器
    GSHWaterLoggingSensor = 3, // 水浸传感器
    GSHInfrareCurtainSensor = 4, // 红外幕帘
    GSHSOSSensor = 5, // 紧急按钮
    GSHAudibleVisualAlarmSensor = 6, // 声光报警器
    GSHInfrareReactionSensor = 7, // 红外人体感应面板
    GSHCoGasSensor = 8, // 一氧化碳传感器
    GSHCombustibleSensor = 9, // 可燃气体传感器
};

@interface GSHAlarmSensorSetVC : GSHDeviceVC

+ (instancetype)alarmSensorSetVCWithDeviceM:(GSHDeviceM *)deviceM
                                 sensorType:(GSHSensorType)sensorType
                             deviceEditType:(GSHDeviceVCType)deviceEditType;

@property (nonatomic , copy) void (^deviceSetCompleteBlock)(NSArray *exts);

@end

NS_ASSUME_NONNULL_END
